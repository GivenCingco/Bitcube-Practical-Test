module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.image_repo_name

  repository_read_write_access_arns = ["arn:aws:iam::009160050878:role/BitcubeEC2ServiceRole"]

  /* ======== Custom repository policy =======*/
  repository_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::009160050878:role/BitcubeEC2ServiceRole" // Correct role
        },
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["latest"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Create the ECR repository with mutable image tags
resource "aws_ecr_repository" "bitcube_repository" {
  name                 = var.image_repo_name
  image_tag_mutability = "MUTABLE"

  # Use the same repository policy as above if needed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}