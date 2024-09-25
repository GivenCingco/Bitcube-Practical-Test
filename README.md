- I first created the nextjs application using sample application provided.
- I then created the Dockerfile in the root of the application files

```bash
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build 

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

- I then created the appspec.yml file. The AppSpec file is a crucial component in AWS CodeDeploy, used to manage deployments.
    - The appspec.yml files has CodeDeploy lifecycles hooks, namely; ApplicationStop, BeforeInstall, AfterInstall, ApplicationStart and ValidateService.
    - The files uses the scripts stored in the folder “script” in the root of the application files.
- I then created the buildspec.yml files. The **buildspec file** is a key component in AWS CodeBuild, used to define the build commands and settings for your build process for CodeDeploy.
- I then also created a .`github` folder where I will store my GitHub actions workflow. Inside the workflows folder there’s a workflow files that will trigger the AWS CodePipeline as soon someone pushes their code to the main branch.

```json
name: Trigger AWS CodePipeline

on:
  push:
    branches: [main]

jobs:
  build:
    name: Trigger-pipeline
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Trigger AWS CodePipeline
        run: | 
            aws codepipeline start-pipeline-execution --name bitcube-pipeline
```

I saved my AWS Account access key and Secret Access key

![Screenshot 2024-09-25 at 01.29.14.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/9eba561f-756e-4cb1-846f-35ad54d582bc/a8356a05-f514-41cf-93a1-e1ac567c3215/Screenshot_2024-09-25_at_01.29.14.png)

- I then compressed project files

# Project Documentation: CI/CD Pipeline for Next.js Application

## Overview

This project implements a complete CI/CD pipeline on AWS for a Next.js web application. The pipeline automates the build, test, and deployment processes, ensuring a streamlined workflow from code changes to application updates.

## Deliverables

1. **Infrastructure as Code**: Terraform or CloudFormation template for infrastructure setup.
2. **Working CodePipeline**: An automated pipeline that builds and deploys the application.
3. **Comprehensive Documentation**: Instructions on setting up, running, and verifying the solution.

## Infrastructure Setup

### Resources Provisioned

- **Hosting Options**: The application is hosted on either an EC2 instance.
- **Automation**: Infrastructure is provisioned using [Terraform/CloudFormation](https://www.notion.so/insert_link_to_template).
- **IAM Roles and Policies**: Configured for CodePipeline, CodeBuild, and CodeDeploy.
- **Artifact Storage**: An S3 bucket is created for storing build artifacts.

### Steps to Provision

1. Clone the repository containing the Terraform/CloudFormation template.
2. Run the relevant commands to deploy the infrastructure.
    - For Terraform:
        
        ```bash
        terraform init
        terraform apply
        
        ```
        
    - For CloudFormation, use the AWS Management Console or CLI to deploy the stack.

# CI/CD Pipeline Configuration

### GitHub Repository Setup

1. Create a GitHub repository for the Next.js application. This the link to the repository https://github.com/GivenCingco/nextjs-blog-bitcube
2. Push the application code to the main branch.
3. Set up GitHub secrets for AWS access:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`

### CodePipeline Configuration

1. **Pipeline Trigger**: The pipeline triggers automatically on pushes to the main branch.
2. **Build Process**: AWS CodeBuild compiles the application.
3. **Deployment**: AWS CodeDeploy deploys the application to the provisioned EC2 instance or Elastic Beanstalk environment.

### GitHub Actions Workflow

The following GitHub Actions workflow triggers the AWS CodePipeline on code changes:

```yaml
name: Trigger AWS CodePipeline

on:
  push:
    branches: [main]

jobs:
  build:
    name: Trigger-pipeline
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Trigger AWS CodePipeline
        run: |
          aws codepipeline start-pipeline-execution --name bitcube-pipeline

```

## Usage Instructions

### Building and Deploying

- Once code is pushed to the main branch, the pipeline automatically initiates.
- CodeBuild will compile the application, and upon success, CodeDeploy will deploy it to the specified environment.

### Accessing the Application

- **EC2 Instance**: Use the public IP address of the EC2 instance.
- **Elastic Beanstalk**: Access the application via the provided Elastic Beanstalk URL.

## Access Instructions

### Connecting to EC2 Instance

1. Use SSH to connect (ensure your security group permits SSH access):
    
    ```bash
    ssh -i /path/to/key.pem ec2-user@your-ec2-public-ip
    
    ```
    

### Application URL

- Access the application in a web browser:
    - For EC2: `http://your-ec2-public-ip`
    - For Elastic Beanstalk: `http://your-elastic-beanstalk-url`

## Troubleshooting Tips

- **Pipeline Failures**: Check AWS CodeBuild logs for errors and AWS CodeDeploy logs for deployment issues.
- **Access Issues**: Verify security group settings allow traffic on necessary ports (e.g., port 80 for HTTP).

## License

This project is licensed under the MIT License. See the [LICENSE](https://www.notion.so/insert_link_to_license) file for more details.

---

Feel free to adjust any sections to better fit your project's specifics, and replace placeholders with actual links or information as needed.

# Documentation for Terraform

**`providers.tf`**

This file sets up the Terraform backend and configures the AWS provider for the infrastructure deployment. It defines an S3 backend for storing the Terraform state file, which ensures that the state is securely managed and supports state locking with a DynamoDB table. The AWS provider is configured to use the us-east-1 region and the default AWS profile for authentication, enabling Terraform to create and manage resources within that specified region.

**`vpc.tf`**

This file creates a Virtual Private Cloud (VPC) in AWS, defining its name, CIDR block, availability zones, and subnets while disabling NAT and VPN gateways. It applies tags for identification and outputs essential details like the VPC ID and public subnet information for easier reference in other configurations.

**`variables.tf`**

This file defines multiple variables used in the Terraform configuration, including the AWS account ID, CodeStar connection credentials, image repository name and tag, AWS region, and S3 bucket name. Each variable includes a description and a default value for easy configuration and reference throughout the infrastructure setup.

**`security_group.tf`**

This module creates a security group for an EC2 instance within a specified VPC, allowing inbound traffic on ports 22 (SSH), 80 (HTTP), and ICMP (for ping requests) from any IP address. It also permits all outbound traffic, ensuring flexibility for the instance’s communication needs, and outputs the security group ID for further reference in the Terraform configuration.

**`codepipeline.tf`**

This code sets up an AWS CodePipeline called “bitcube-pipeline” to manage the build and deployment of a Next.js application. It includes three stages: Source (fetching code from GitHub via a CodeStar connection), Build (compiling with AWS CodeBuild), and Deploy (deploying with AWS CodeDeploy), while also creating a GitHub CodeStar connection and enhancing S3 bucket security by blocking public access.

**`ssm_parameters.tf`**

This code snippet defines several AWS SSM parameters to store configuration values securely. It includes parameters for the AWS region, ECR repository name, Docker image tag, and container name, allowing for easy access and management of these settings within your application. Each parameter is created with a specific name, type, and value, ensuring that essential configurations are readily available for use in other parts of your infrastructure.

**`key_pair.tf`**

This code creates an EC2 key pair using a Terraform module and generates a new RSA private key. It stores the private and public keys in AWS Secrets Manager for secure access, ensuring sensitive information is managed safely.

**`iam_roles.tf`**

This snippet creates IAM roles and policies for various AWS services such as EC2, CodeBuild, and CodeDeploy. It starts by generating a unique random string to ensure unique naming for resources. ***The aws_iam_role*** resource sets up a service role for EC2 instances, allowing them to assume specific permissions defined by attached policies. Each policy grants necessary access to services like ECR, S3, and SSM. The ***aws_iam_instance_profile*** resource links the EC2 role to instances at launch.

`ecr.tf`

This code creates an Amazon ECR (Elastic Container Registry) repository with specific permissions for an EC2 service role, a lifecycle policy to retain the last 30 tagged images, and enables image scanning on push. It also allows for mutable image tags and assigns tags for Terraform management and environment designation.

`ec2.tf`

This code creates an EC2 instance named “Bitcube-ec2” using Terraform. It sets the instance type, key pair, security group, subnet, and AMI. The user data script installs Docker and the CodeDeploy agent. The instance is tagged for CodeDeploy to identify it for deploying the ***Next.js*** application; without this tag, CodeDeploy cannot determine which instance to use.

`code_deploy.tf`

This code creates a CodeDeploy application named “***BitcubeNextjsApp***” and a deployment group “BitcubeDeploymentGroup1.” The group uses an IAM role and filters EC2 instances by the “Environment” tag set to “BitcubeCodeDeploy.” It also enables automatic rollback on deployment failures.

**`code_build.tf`**

This code sets up an AWS CodeBuild project named “Bitcube-Practical-Test” to build a Bitcube application from a GitHub repository. It specifies build instructions in buildspec.yml, uses a Linux container, and configures environment variables for AWS settings. Logs are sent to CloudWatch, and no build artifacts are generated.

`bucket.tf` 

This code creates an S3 bucket named “bitcube-pipeline-artifacts” using the terraform-aws-modules/s3-bucket module. The bucket is set to private, with object ownership configured to “ObjectWriter” and versioning disabled. The bucket ID is outputted for reference.

`.gitignore`

The ***.gitignore*** file is essential for preventing large and sensitive files, such as Terraform state files and private keys, from being pushed to a Git repository, thus maintaining a clean, efficient, and secure codebase.

`.terraform.lock.hcl`

The ***.terraform.lock.hcl*** file is used by Terraform to manage provider dependencies and their versions, ensuring that the same versions of providers are used across different environments and by different team members, which helps maintain consistency and stability in infrastructure deployments.
