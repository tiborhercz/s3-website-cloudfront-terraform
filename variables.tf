variable "domain_name" {
  type        = string
  description = "domain name of the website"
}

variable "acm_certificate_arn" {
  type        = string
  description = "arn of the SSL certificate"
}
