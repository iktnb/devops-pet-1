# Specify the AWS provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# EC2 Instance in US East (N. Virginia) region
resource "aws_instance" "us_east_server" {
  ami           = "ami-0c02fb55956c7d316" # Example Ubuntu AMI in us-east-1
  instance_type = "t2.micro"

  tags = {
    Name = "US_East_Server"
  }
}

# S3 Bucket for static files
resource "aws_s3_bucket" "static_bucket" {
  bucket = "iktnb-pet-first-s3-bucket" # Replace with a unique bucket name

  tags = {
    Name = "StaticFilesBucket"
  }
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "static_bucket_website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# CloudFront Origin Access Control (Corrected)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                               = "S3OAC"
  description                        = "OAC for S3 Bucket"
  origin_access_control_origin_type  = "s3"
  signing_behavior                   = "always"
  signing_protocol                   = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront CDN for static files"
  default_root_object = "index.html"

  aliases = ["dev.iktnb.com"] # Custom domain name

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
    cloudfront_default_certificate = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "StaticFilesCDN"
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}

# S3 Bucket Policy to allow CloudFront OAC access
resource "aws_s3_bucket_policy" "static_bucket_policy" {
  bucket = aws_s3_bucket.static_bucket.id

  policy = data.aws_iam_policy_document.s3_policy.json
}

# Policy Document for S3 Bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "AllowCloudFrontAccess"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

# Request ACM Certificate for dev.iktnb.com in us-east-1
resource "aws_acm_certificate" "cert" {
  domain_name       = "dev.iktnb.com"
  validation_method = "DNS"

  tags = {
    Name = "dev.iktnb.com Certificate"
  }
}

# DNS Validation Records for ACM Certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Validate ACM Certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route53 Zone Data (assuming you have a hosted zone)
data "aws_route53_zone" "main" {
  name         = "iktnb.com."
  private_zone = false
}

# Route53 Record to point dev.iktnb.com to CloudFront
resource "aws_route53_record" "dev_subdomain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "dev"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}