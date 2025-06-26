variable "bucket_name" {
  description = "Name of the S3 bucket. This needs to be global unique"
}

variable "region" {
  default = "eu-central-1"
}

variable "domain_name" {
  description = "Default hostname to be allowed by cloudfront"
}

variable "acm_cert_arn" {
  description = "ARN of the SSL cert to be used on cloudfront"
}

