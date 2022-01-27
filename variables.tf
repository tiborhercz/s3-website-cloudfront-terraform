variable "domain_name" {
  type        = string
  description = "Website domain name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}

variable "website_referer" {
  type = string
  description = "Referer string only allowing access to bucket object when this referer header is set. Use a random, not predictable string. Example: ZJAibno2C7NjHqBmqh9Q"
}
