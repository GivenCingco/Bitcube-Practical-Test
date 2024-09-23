module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "bitcube-image2"

     

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