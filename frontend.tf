locals {
  s3_origin_id = "s3-photopremium"
}

// s3 bucket for code (static files)

data "aws_iam_policy_document" "photopremium-document-s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.photopremium-access-identity.iam_arn]
      type = "AWS"
    }
    resources = ["${aws_s3_bucket.photopremium-dev-static-files.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "photopremium-s3_policy" {
  bucket = aws_s3_bucket.photopremium-dev-static-files.id
  policy = data.aws_iam_policy_document.photopremium-document-s3_policy.json
}


resource "aws_s3_bucket" "photopremium-dev-static-files" {
  bucket = var.cloudfront_dns
  acl = var.s3_bucket_acl

  website {
    error_document = "index.html"
    index_document = "index.html"
  }

  tags = {
    Name = var.cloudfront_dns
  }
}

// cloud front distribution

resource "aws_cloudfront_origin_access_identity" "photopremium-access-identity" {
}

resource "aws_cloudfront_distribution" "photopremium-cdn" {
  origin {
    domain_name = aws_s3_bucket.photopremium-dev-static-files.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.photopremium-access-identity.cloudfront_access_identity_path
    }
  }
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [var.cloudfront_dns]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 60
    max_ttl = 60

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
    acm_certificate_arn = var.certificate_arn_front
    cloudfront_default_certificate = false
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  custom_error_response {
    error_caching_min_ttl = 10 
    error_code            = 403 
    response_code         = 200 
    response_page_path    = "/index.html" 
  }

  custom_error_response {
    error_caching_min_ttl = 10 
    error_code            = 404 
    response_code         = 200 
    response_page_path    = "/index.html" 
  }
}