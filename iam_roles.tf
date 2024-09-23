/* ======== Create IAM Role for EC2 =======*/
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

/* ======== Attach AmazonEC2ContainerRegistryReadOnly policy =======*/
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

/* ======== Attach AmazonS3ReadOnlyAccess policy =======*/
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

/* ======== Attach AmazonSSMReadOnlyAccess policy =======*/
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


/* ======== Attach policies to the EC2 Service Role =======*/
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

/* ======== Attach the AmazonEC2RoleforSSM managed policy =======*/
resource "aws_iam_role_policy_attachment" "attach_ec2_ssm_policy" {
  role       = aws_iam_role.bitcube_ec2_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

/* ======== Create an IAM Instance Profile to be used by EC2 =======*/
resource "aws_iam_instance_profile" "bitcube_ec2_instance_profile" {
  name = "BitcubeEC2InstanceProfile"
  role = aws_iam_role.bitcube_ec2_service_role.name
}