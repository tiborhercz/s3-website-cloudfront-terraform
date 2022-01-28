resource "aws_cloudfront_distribution" "distribution" {
  enabled     = true
  aliases     = [var.domain_name]
  price_class = "PriceClass_100"

  origin {
    domain_name = "${aws_s3_bucket.website.id}.${aws_s3_bucket.website.website_domain}"
    origin_id   = local.s3_origin_id

    connection_attempts = 3
    connection_timeout  = 10

    custom_header {
      name  = "referer"
      value = random_password.referer
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    compress                   = true
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers_policy.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_identity" "blog" {
  comment = "blog-website-bucket"
}

data "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "Managed-SecurityHeadersPolicy"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}
