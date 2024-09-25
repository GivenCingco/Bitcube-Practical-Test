# # Store AWS Region in SSM Parameter Store
# resource "aws_ssm_parameter" "aws_region" {
#   name  = "/myapp/aws-region"
#   type  = "String"
#   value = "us-east-1" # Change this to your AWS region
# }

# # Store ECR Repository Name in SSM Parameter Store
# resource "aws_ssm_parameter" "ecr_repository" {
#   name  = "/myapp/ecr-repository"
#   type  = "String"
#   value = "my-nextjs-app-repo" # Replace with your ECR repository name
# }

# # Store Docker Image Tag in SSM Parameter Store
# resource "aws_ssm_parameter" "image_tag" {
#   name  = "/myapp/image-tag"
#   type  = "String"
#   value = "latest" 
# }

# # Store Container Name in SSM Parameter Store
# resource "aws_ssm_parameter" "container_name" {
#   name  = "/myapp/container-name"
#   type  = "String"
#   value = "nextjs-container" # Replace with your desired container name
# }