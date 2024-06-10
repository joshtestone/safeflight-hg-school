variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}
