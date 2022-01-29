variable "domain_name" {
  type        = string
  description = "Website domain name. Example: example.com"
}

variable "redirect_domain_name" {
  type        = string
  description = "Redirects to the domain set in the variable 'domain_name'. Example: www.example.com"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}
