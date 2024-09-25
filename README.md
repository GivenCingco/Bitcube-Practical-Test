# Documentation for Terraform

In this repository, I have included the Terraform code used to deploy my AWS infrastructure, along with an explanation of the purpose of each file below.

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


# Brief set of instructions about the environment and how the CI/DC pipeline works.
## 
I first created an S3 bucket to store the Terraform state file and a DynamoDB table for state locking. The remote S3 setup facilitates collaboration, while the DynamoDB table ensures that the state is locked, preventing simultaneous changes by multiple users.

Next, I initialized the repository to install all the Terraform dependencies. I ran the terraform plan command to view the execution plan without committing any changes. If I was satisfied with the plan, I would then execute terraform apply --auto-approve, using the --auto-approve flag to avoid manually confirming changes each time.

Additionally, I created an AWS CodeStar connection between GitHub and my AWS account and set up parameters in the Parameter Store, including account ID, AWS region, container name, ECR repository, and image tag. These parameters will be used by CodeBuild, allowing values to be pulled directly from the Parameter Store instead of hardcoding them in the buildspec.yml file, which enhances security and maintainability.

# First step in AWS CodePipeline
When a user pushes code to the main branch of a GitHub repository, this action triggers an AWS CodePipeline through a GitHub Action configured to initiate the pipeline. The first step in the pipeline is the Source step, where the code is fetched from the GitHub repository using the AWS CodeStar connection.

Once the code is retrieved, AWS CodeBuild is triggered to build the application. CodeBuild uses the buildspec.yml file to define the build process, 
which consists of several phases: *Pre-build phase*, *Build phase* and *post-build phase*. During the build process, once the Docker image is built and tagged, it is pushed to Amazon ECR, where it is securely stored. ECR allows for easy management of Docker images, enabling the user to pull the images for deployment in subsequent steps of the pipeline.

# Second step in AWS CodePipeline
After the Docker image is successfully pushed to Amazon ECR, AWS CodeDeploy is triggered to manage the application deployment. CodeDeploy retrieves the newly built image from ECR and deploys it to a specified deployment group, which includes a set of EC2 instances identified by tags. This setup ensures that the latest version of the application runs in the production environment, supporting continuous deployment practices. 

# Third and final step in the AWS CodePipeline 
In the final step of the AWS pipeline, AWS CodeDeploy is responsible for deploying the application to the EC2 instance. The EC2 instance has a user data script that installs dependencies, Docker, and the AWS CodeDeploy agent. During this stage, AWS CodeDeploy fetches the zipped application files stored in S3, including the appspec.yml file that contains the lifecycle hook scripts.

After these scripts execute, AWS CodeDeploy continues with the deployment process by fetching parameters stored in the Parameter Store. These parameters, such as the Docker image tag and repository name, are used to pull the latest Docker image from ECR and deploy it to the EC2 instance.

This structured approach facilitates a seamless deployment, ensuring that the latest version of the application is running smoothly on the specified EC2 instance.

# Access the application
* To access the application, navigate to the EC2 instance details, find the Public IPv4 address, and enter it in a new browser window.
* You can also SSH into your instance
```
ssh -i /path/to/your-key.pem ec2-user@<Public-IP-Address>

```
  

