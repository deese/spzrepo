# 🔐 CloudFront OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "apt-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 🌐 CloudFront + domain
resource "aws_cloudfront_distribution" "apt_cf" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.apt_repo.bucket_regional_domain_name
    origin_id   = "aptRepoS3Origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "aptRepoS3Origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "APT CloudFront"
  }
}

