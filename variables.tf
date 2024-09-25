variable "account_id" {
  description = "AWS account ID"
  type        = string
  default = "009160050878"
}

variable "codestart_connector_cred" {
  type = string
  default = "arn:aws:codeconnections:us-east-1:009160050878:connection/b15fbc4a-7e99-486b-b571-fbc88dff0d19"
  description = "Variable for CodeStar connection credentials"

}

variable "image_repo_name" {
  description = "Image repo name"
  type        = string
  default     = "bitcube-image"
}

variable "image_tag" {
  description = "Image tag"
  type        = string
  default     = "latest"
}


variable "region" {
  description = "Reigon"
  type        = string
  default     = "us-east-1"
}

variable "bucket" {
  description = "Bucket "
  type        = string
  default     = "given-cingco-devops-directive-tf-state"
}