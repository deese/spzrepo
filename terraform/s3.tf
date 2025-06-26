# 🪣 Private S3 
resource "aws_s3_bucket" "apt_repo" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.apt_repo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🔓 S3 Policy that grants Cloudfront access only
resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.apt_repo.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Action   = "s3:GetObject",
      Resource = "${aws_s3_bucket.apt_repo.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.apt_cf.arn
        }
      }
    }]
  })
}

