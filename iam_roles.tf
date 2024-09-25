resource "random_string" "unique_suffix" {
  length  = 8
  special = false
}



/* ======================= Create IAM Role for EC2 ========================*/
resource "aws_iam_role" "bitcube_ec2_service_role" {
  name = "BitcubeEC2ServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


#Attach AmazonEC2ContainerRegistryReadOnly policy
resource "aws_iam_policy" "ecr_readonly_policy" {
  name        = "AmazonEC2ContainerRegistryReadOnlyPolicy"
  description = "Amazon ECR ReadOnly Policy"


  policy = jsonencode(
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": "*"
        }
    ]
}
  
  )
}

#Attach AmazonS3ReadOnlyAccess policy
resource "aws_iam_policy" "s3_readonly_policy" {
  name        = "AmazonS3ReadOnlyAccessPolicy"
  description = "Amazon S3 ReadOnly Access Policy"

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
}
  )
}

#Attach AmazonSSMReadOnlyAccess policy
resource "aws_iam_policy" "ssm_readonly_policy" {
  name        = "AmazonSSMReadOnlyAccessPolicy"
  description = "Amazon SSM ReadOnly Access Policy"

  policy = jsonencode(
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*"
            ],
            "Resource": "*"
        }
    ]
}
  )
}


#Attach policies to the EC2 Service Role
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.bitcube_ec2_service_role.name
  policy_arn = aws_iam_policy.ecr_readonly_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.bitcube_ec2_service_role.name
  policy_arn = aws_iam_policy.s3_readonly_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.bitcube_ec2_service_role.name
  policy_arn = aws_iam_policy.ssm_readonly_policy.arn
}

#Attach the AmazonEC2RoleforSSM managed policy
resource "aws_iam_role_policy_attachment" "attach_ec2_ssm_policy" {
  role       = aws_iam_role.bitcube_ec2_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#Create an IAM Instance Profile to be used by EC2
resource "aws_iam_instance_profile" "bitcube_ec2_instance_profile" {
  name = "BitcubeEC2InstanceProfile"
  role = aws_iam_role.bitcube_ec2_service_role.name
}






/* ============================== CodeBuild IAM Role ================================*/
# Assume the default service role created by CodeBuild
resource "aws_iam_role" "codebuild_default_role" {
  name               = "CodeBuildBasePolicy-BitcubeCodeBuild-us-east-1"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_s3_access_policy" {
  name        = "CodeBuildS3AccessPolicy"
  description = "Policy to allow CodeBuild to access S3 artifacts"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::bitcube-codepipeline-bucket",
                "arn:aws:s3:::bitcube-codepipeline-bucket/bitcube-pipeline/*"
            ]
        }
    ]
}
EOF
}

# Attach the policy to the CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_s3_access_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_s3_access_policy.arn
}

# Policy 1: CodeBuildBasePolicy
resource "aws_iam_policy" "codebuild_base_policy" {
  name        = "CodeBuildBasePolicy-BitcubeCodeBuild-${random_string.unique_suffix.result}"
  description = "Policy for Bitcube CodeBuild"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:${var.account_id}:log-group:/aws/codebuild/BitcubeCodeBuild",
                "arn:aws:logs:us-east-1:${var.account_id}:log-group:/aws/codebuild/BitcubeCodeBuild:*"
            ]
        },
  {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::bitcube-codepipeline-bucket", 
                "arn:aws:s3:::bitcube-codepipeline-bucket/*" 
            ]
        },

        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-east-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:us-east-1:${var.account_id}:report-group/BitcubeCodeBuild-*"
            ]
        }
    ]
}
EOF
}

# Policy 2: CodeBuildCloudWatchLogsPolicy
resource "aws_iam_policy" "codebuild_cloudwatch_logs_policy" {
  name        = "CodeBuildCloudWatchLogsPolicy-BitcubeCodeBuild-${random_string.unique_suffix.result}"
  description = "Policy for CloudWatch Logs in CodeBuild"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:009160050878:log-group:CodeBuildBitcube",
                "arn:aws:logs:us-east-1:009160050878:log-group:CodeBuildBitcube:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        }
    ]
}
EOF
}

# Policy 3: CodeBuildCodeConnectionsSourceCredentialsPolicy
resource "aws_iam_policy" "codebuild_connections_policy" {
  name        = "CodeBuildCodeConnectionsSourceCredentialsPolicy-BitcubeCodeBuild-${random_string.unique_suffix.result}"
  description = "Policy for CodeStar Connections in CodeBuild"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codestar-connections:GetConnectionToken",
                "codestar-connections:GetConnection",
                "codeconnections:GetConnectionToken",
                "codeconnections:GetConnection",
                "codeconnections:UseConnection"
            ],
            "Resource": [
                "arn:aws:codestar-connections:us-east-1:${var.account_id}:connection/b15fbc4a-7e99-486b-b571-fbc88dff0d19",
                "arn:aws:codeconnections:us-east-1:${var.account_id}:connection/b15fbc4a-7e99-486b-b571-fbc88dff0d19"
            ]
        }
    ]
}
EOF
}

# Attach the policies to the default CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_base_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_base_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_connections_policy_attachment" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = aws_iam_policy.codebuild_connections_policy.arn
}

# Attach the AWS Managed Policy to the default service role
resource "aws_iam_role_policy_attachment" "attach_ec2_instance_profile_policy" {
  role       = aws_iam_role.codebuild_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}





/* ============================== CodeDeploy ================================*/
# Assume the default service role created by CodeDeploy
resource "aws_iam_role" "codedeploy_default_role" {
  name               = "CodeDeployBasePolicy-BitcubeCodeDeploy-us-east-1"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach CodeDeploy policy
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Attach SSM Read-Only Access
resource "aws_iam_role_policy_attachment" "codedeploy_role_ssm_readonly" {
  role       = aws_iam_role.codedeploy_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Attach S3 permissions
resource "aws_iam_role_policy" "codedeploy_s3_policy" {
  name   = "CodeDeployS3Access"
  role   = aws_iam_role.codedeploy_default_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bitcube-codepipeline-bucket",
        "arn:aws:s3:::bitcube-codepipeline-bucket/*"
      ]
    }
  ]
}
EOF
}


#Attach CodeDeploy policy
# resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
#   role       = aws_iam_role.codedeploy_default_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
# }


#Attach SSM Read-Only Access
# resource "aws_iam_role_policy_attachment" "codedeploy_role_ssm_readonly" {
#   role       = aws_iam_role.codedeploy_default_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

#Attach AWS CodeDeploy role
resource "aws_iam_role_policy_attachment" "codedeploy_role_codedeploy" {
  role       = aws_iam_role.codedeploy_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

/* ============================== Allow CodeDeploy to Access S3 ================================*/
resource "aws_s3_bucket_policy" "codedeploy_access" {
  bucket = "given-cingco-devops-directive-tf-state"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action    = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = "arn:aws:s3:::given-cingco-devops-directive-tf-state/*"
      }
    ]
  })
}





/*================== CodePipeline============== */


resource "aws_iam_role" "codepipeline-role" {
  name = "CodepipelineServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

/* CodePipeline IAM Policies */
data "aws_iam_policy_document" "cicd-pipeline-policies" {
  # Existing statements...

  # Additional permissions based on your request
  statement {
    sid      = ""
    actions  = [
      "iam:PassRole"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "ecr:DescribeImages"
    ]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = ["*"]
    effect   = "Allow"
  }
}

/* Attach Policy to CodePipeline Role */
resource "aws_iam_policy" "cicd-pipeline-policy" {
  name        = "cicd-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.cicd-pipeline-policy.arn
  role       = aws_iam_role.codepipeline-role.id
}


resource "aws_iam_policy" "codepipeline_s3_access_policy" {
  name        = "CodePipelineS3AccessPolicy"
  description = "Policy to allow CodePipeline to access S3 artifacts"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::bitcube-codepipeline-bucket",
          "arn:aws:s3:::bitcube-codepipeline-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attachment" {
  role       = aws_iam_role.codepipeline-role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_access_policy_attachment" {
  role       = aws_iam_role.codepipeline-role.name
  policy_arn = aws_iam_policy.codepipeline_s3_access_policy.arn
}

resource "aws_s3_bucket_policy" "codepipeline_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::009160050878:role/${aws_iam_role.codepipeline-role.name}"
        },
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
        "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}",    
        "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*" 
        ]
      }
    ]
  })
}
