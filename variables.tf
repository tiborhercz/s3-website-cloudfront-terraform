variable "domain_name" {
  type        = string
  description = "Website domain name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}
