# AWS Automated Incident Response System

This project implements an automated incident response system in AWS using Terraform. It integrates key AWS services like Lambda, CloudWatch, GuardDuty, Step Functions, and S3 for detecting and responding to security incidents automatically.

## Project Structure

- **terraform/**: Contains Terraform scripts to set up the automated incident response system.
- **lambda/**: Contains Lambda function code for handling security incidents.
- **s3/**: Stores incident logs and Lambda code in S3 with encryption and versioning.
- **step-functions/**: Defines workflows to automate responses to security events.

## Prerequisites

- **Terraform v1.0+**
- **AWS CLI**
- **AWS Account with programmatic access**
- **Zip file (`incident_handler.zip`) with the Lambda function code**

## Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/aws-incident-response-system.git
   cd aws-incident-response-system
   ```

2. **Update your AWS configuration**:
   - Modify the `terraform.tfvars` file with your AWS region and credentials if required.

3. **Prepare the Lambda function code**:
   - Ensure that `incident_handler.zip` containing your Lambda code is located at `Desktop/aws2024/incident-response-system/`.
   
4. **Run Terraform commands**:
   ```bash
   terraform init
   terraform apply
   ```

## Usage

- **GuardDuty**: Detects potential security threats within your AWS account, such as unauthorized API calls or unusual network activity.
- **CloudWatch Alarms**: Triggers alarms based on security metrics (e.g., unauthorized API calls) and alerts via SNS.
- **Lambda Functions**: Automatically responds to security incidents (e.g., disabling compromised instances).
- **S3**: Logs and stores the details of the security incident for auditing and future reference.

## Incident Response Workflow

1. **Threat Detection**: AWS GuardDuty monitors for suspicious activities.
2. **Trigger Alarm**: If a threat is detected, CloudWatch triggers an alarm.
3. **SNS Notification**: SNS sends a notification to the incident response Lambda function.
4. **Automated Response**: The Lambda function handles the response (e.g., revokes credentials, blocks IP addresses).
5. **Logging**: All actions are logged to the S3 bucket with encryption and versioning enabled.

## Security Tools

- **AWS GuardDuty**: Monitors for potential threats.
- **CloudWatch Alarms**: Tracks and responds to unauthorized API calls.
- **AWS Lambda**: Executes incident response actions.
- **AWS Step Functions**: Automates workflows for handling security events.
- **S3**: Stores and versions logs securely.

## Contribution

Feel free to submit issues or pull requests for improvements or additional features.

## License

This project is licensed under the MIT License.
