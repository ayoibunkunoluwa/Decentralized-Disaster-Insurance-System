;; Claim Verification Contract
;; Validates disaster damage through satellite imagery

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-CLAIM (err u301))
(define-constant ERR-CLAIM-EXISTS (err u302))
(define-constant ERR-CLAIM-NOT-FOUND (err u303))
(define-constant ERR-INVALID-EVIDENCE (err u304))
(define-constant ERR-CLAIM-ALREADY-PROCESSED (err u305))

;; Data Variables
(define-data-var next-claim-id uint u1)

;; Data Maps
(define-map insurance-claims
  { claim-id: uint }
  {
    policy-id: uint,
    claimant: principal,
    disaster-type: (string-ascii 30),
    damage-amount: uint,
    claim-date: uint,
    incident-date: uint,
    status: (string-ascii 20),
    verification-score: uint
  }
)

(define-map claim-evidence
  { claim-id: uint, evidence-id: uint }
  {
    evidence-type: (string-ascii 30),
    data-hash: (buff 32),
    satellite-coords: { lat: int, lng: int },
    timestamp: uint,
    verified: bool
  }
)

(define-map verification-results
  { claim-id: uint }
  {
    damage-confirmed: bool,
    estimated-damage: uint,
    confidence-score: uint,
    verifier: principal,
    verification-date: uint,
    notes: (string-ascii 200)
  }
)

(define-map authorized-verifiers
  { verifier: principal }
  {
    active: bool,
    specialization: (string-ascii 50),
    verification-count: uint
  }
)

;; Private Functions
(define-private (calculate-verification-score (evidence-count uint) (satellite-quality uint) (damage-consistency uint))
  (let
    (
      (evidence-factor (if (> evidence-count u3) u100 (* evidence-count u25)))
      (quality-factor satellite-quality)
      (consistency-factor damage-consistency)
    )
    (/ (+ evidence-factor (+ quality-factor consistency-factor)) u3)
  )
)

(define-private (validate-damage-estimate (claimed-amount uint) (estimated-amount uint))
  (let
    (
      (variance (if (> claimed-amount estimated-amount)
                   (- claimed-amount estimated-amount)
                   (- estimated-amount claimed-amount)))
      (variance-ratio (/ (* variance u100) claimed-amount))
    )
    (< variance-ratio u25) ;; Allow 25% variance
  )
)

;; Public Functions
(define-public (submit-claim
  (policy-id uint)
  (disaster-type (string-ascii 30))
  (damage-amount uint)
  (incident-date uint))
  (let
    (
      (claim-id (var-get next-claim-id))
    )
    (asserts! (> damage-amount u0) ERR-INVALID-CLAIM)
    (asserts! (< incident-date block-height) ERR-INVALID-CLAIM)
    (asserts! (> incident-date (- block-height u52560)) ERR-INVALID-CLAIM) ;; Within 1 year

    (map-set insurance-claims
      { claim-id: claim-id }
      {
        policy-id: policy-id,
        claimant: tx-sender,
        disaster-type: disaster-type,
        damage-amount: damage-amount,
        claim-date: block-height,
        incident-date: incident-date,
        status: "submitted",
        verification-score: u0
      }
    )

    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)

(define-public (submit-evidence
  (claim-id uint)
  (evidence-id uint)
  (evidence-type (string-ascii 30))
  (data-hash (buff 32))
  (latitude int)
  (longitude int))
  (let
    (
      (claim-data (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR-CLAIM-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get claimant claim-data)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status claim-data) "submitted") ERR-CLAIM-ALREADY-PROCESSED)

    (map-set claim-evidence
      { claim-id: claim-id, evidence-id: evidence-id }
      {
        evidence-type: evidence-type,
        data-hash: data-hash,
        satellite-coords: { lat: latitude, lng: longitude },
        timestamp: block-height,
        verified: false
      }
    )
    (ok true)
  )
)

(define-public (verify-claim
  (claim-id uint)
  (damage-confirmed bool)
  (estimated-damage uint)
  (confidence-score uint)
  (notes (string-ascii 200)))
  (let
    (
      (claim-data (unwrap! (map-get? insurance-claims { claim-id: claim-id }) ERR-CLAIM-NOT-FOUND))
      (verifier-data (unwrap! (map-get? authorized-verifiers { verifier: tx-sender }) ERR-NOT-AUTHORIZED))
    )
    (asserts! (get active verifier-data) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status claim-data) "submitted") ERR-CLAIM-ALREADY-PROCESSED)
    (asserts! (< confidence-score u101) ERR-INVALID-CLAIM)

    (map-set verification-results
      { claim-id: claim-id }
      {
        damage-confirmed: damage-confirmed,
        estimated-damage: estimated-damage,
        confidence-score: confidence-score,
        verifier: tx-sender,
        verification-date: block-height,
        notes: notes
      }
    )

    (map-set insurance-claims
      { claim-id: claim-id }
      (merge claim-data {
        status: (if damage-confirmed "verified" "rejected"),
        verification-score: confidence-score
      })
    )

    (map-set authorized-verifiers
      { verifier: tx-sender }
      (merge verifier-data { verification-count: (+ (get verification-count verifier-data) u1) })
    )

    (ok true)
  )
)

(define-public (authorize-verifier
  (verifier principal)
  (specialization (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set authorized-verifiers
      { verifier: verifier }
      {
        active: true,
        specialization: specialization,
        verification-count: u0
      }
    )
    (ok true)
  )
)

(define-public (deactivate-verifier (verifier principal))
  (let
    (
      (verifier-data (unwrap! (map-get? authorized-verifiers { verifier: verifier }) ERR-NOT-AUTHORIZED))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set authorized-verifiers
      { verifier: verifier }
      (merge verifier-data { active: false })
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-claim-info (claim-id uint))
  (map-get? insurance-claims { claim-id: claim-id })
)

(define-read-only (get-claim-evidence (claim-id uint) (evidence-id uint))
  (map-get? claim-evidence { claim-id: claim-id, evidence-id: evidence-id })
)

(define-read-only (get-verification-result (claim-id uint))
  (map-get? verification-results { claim-id: claim-id })
)

(define-read-only (get-verifier-info (verifier principal))
  (map-get? authorized-verifiers { verifier: verifier })
)

(define-read-only (get-next-claim-id)
  (var-get next-claim-id)
)
