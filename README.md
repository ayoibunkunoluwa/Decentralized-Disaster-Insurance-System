# Decentralized Disaster Insurance System

A comprehensive blockchain-based disaster insurance platform built on Stacks using Clarity smart contracts.

## Overview

This system provides decentralized disaster insurance through five interconnected smart contracts that handle risk assessment, premium calculation, claim verification, emergency funding, and recovery planning.

## Architecture

### Core Contracts

1. **Risk Assessment Contract** (`risk-assessment.clar`)
    - Evaluates property vulnerability to natural disasters
    - Assigns risk scores based on location, property type, and historical data
    - Maintains disaster probability matrices

2. **Premium Calculation Contract** (`premium-calculation.clar`)
    - Determines insurance costs based on risk factors
    - Implements dynamic pricing algorithms
    - Handles coverage amount calculations

3. **Claim Verification Contract** (`claim-verification.clar`)
    - Validates disaster damage through satellite imagery analysis
    - Processes claim submissions and evidence
    - Manages claim approval workflow

4. **Emergency Fund Contract** (`emergency-fund.clar`)
    - Provides immediate assistance during catastrophes
    - Manages emergency fund pool and distributions
    - Handles rapid response payments

5. **Recovery Planning Contract** (`recovery-planning.clar`)
    - Coordinates rebuilding efforts and resources
    - Manages contractor networks and material supplies
    - Tracks recovery progress and milestones

## Key Features

- **Decentralized Risk Assessment**: Automated evaluation using multiple data sources
- **Dynamic Premium Pricing**: Real-time adjustments based on risk factors
- **Transparent Claims Process**: Immutable record of all claim activities
- **Emergency Response**: Immediate fund access during disasters
- **Recovery Coordination**: Streamlined rebuilding process management

## Data Structures

### Property Information
- Location coordinates and region classification
- Property type, age, and construction materials
- Historical disaster exposure and damage records

### Risk Metrics
- Disaster probability scores (earthquake, flood, hurricane, wildfire)
- Vulnerability assessments and mitigation factors
- Regional risk multipliers and seasonal adjustments

### Insurance Policies
- Coverage amounts and deductible levels
- Premium payment schedules and policy terms
- Beneficiary information and claim history

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for contract deployment

### Installation

\`\`\`bash
git clone <repository-url>
cd decentralized-disaster-insurance
npm install
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy
\`\`\`

## Usage Examples

### Creating a Policy
1. Submit property information for risk assessment
2. Receive premium quote based on risk score
3. Pay premium and activate coverage
4. Monitor policy status and renewal dates

### Filing a Claim
1. Submit claim with disaster event details
2. Provide damage evidence and documentation
3. Await verification through satellite imagery
4. Receive approved claim payment

### Emergency Assistance
1. Declare emergency during active disaster
2. Request immediate fund access
3. Receive emergency payment for critical needs
4. Begin recovery planning process

## Security Considerations

- All contracts implement proper access controls
- Fund management includes multi-signature requirements
- Claim verification uses multiple data sources
- Emergency procedures have built-in safeguards

## Contributing

Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License.
