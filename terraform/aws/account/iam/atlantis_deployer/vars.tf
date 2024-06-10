variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "atlantis_account_id" {
  description = "AWS account ID where Atlantis resides"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}
