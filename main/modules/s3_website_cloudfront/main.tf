provider "aws" {
  region  = var.region
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    version = "~> 4.2"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
     external = {
      source = "hashicorp/external"
      version = "~> 2.2"
    }
  }
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.environment}-${var.application_name}"

}


resource "aws_s3_bucket_policy" "allow_cloudfront_oai" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3-frontend-website-getlist-iam-policy.json
}

data "aws_iam_policy_document" "s3-frontend-website-getlist-iam-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*"    ]
  }
}
resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "${var.environment} website frontend"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.website_bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
 s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} distribution"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  #aliases = []

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "${local.application_path}/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


 # price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "${var.environment}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  module "s3_objects" {
    source = "${path.module}../s3_object"
  bucket = aws_s3_bucket.website_bucket.id

  }
}

