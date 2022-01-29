locals {
  s3_origin_id          = aws_s3_bucket.website.id
  s3_redirect_origin_id = aws_s3_bucket.redirect.id
}
