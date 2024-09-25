# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "bitcube-codepipeline-bucket"
# }

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "bitcube-pipeline-artifacts"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

output "bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}