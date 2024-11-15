variable "account_id" {
  description = "AWS account ID"
  type        = string
  default = "135808943588"
}

variable "codestart_connector_cred" {
  type = string
  default = "arn:aws:codeconnections:eu-west-2:135808943588:connection/879b3b40-801e-4948-a68c-e1a02853bb91"
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
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket" {
  description = "Bucket "
  type        = string
  default     = "given-cingco-devops-directive-tf-state-ccadcadv"
}

variable "github_url" {
  description = "source of the buildpec file on GitHub "
  type        = string
  default     = "https://github.com/givencingco-bitcube/karmah-web-main-copy"
}
