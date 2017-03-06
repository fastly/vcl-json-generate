variable "fastly_api_key" {
  type        = "string"
  description = "Fastly API key"
}

variable "domain" {
  type        = "string"
  description = "Domain name"
}

variable "papertrail_address" {
  type        = "string"
  description = "Papertrail address"
}

variable "papertrail_port" {
  type        = "string"
  description = "Papertrail port"
}
