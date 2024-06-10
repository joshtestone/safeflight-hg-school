variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "cluster_admins" {
  type        = list(string)
  description = "A list containing the ARNs of users/roles that should be cluster administrators."
  default     = []
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "The version of Kubernetes to run for the EKS cluster."
  default     = "1.29"
}

variable "cluster_wait" {
  type        = string
  description = "The time to wait after cluster creation before attempting to deploy resources."
  default     = "60s"
}

variable "deploy_argocd" {
  type        = bool
  description = "A boolean representing whether or not to deploy ArgoCD in the EKS cluster."
  default     = false
}

variable "deploy_atlantis" {
  type        = bool
  description = "A boolean representing whether or not to deploy Atlantis in the EKS cluster."
  default     = false
}

variable "deploy_wiz" {
  type        = bool
  description = "A boolean representing whether or not to deploy Wiz connector/components in the EKS cluster."
  default     = false
}

variable "deploy_external_secrets" {
  type        = bool
  description = "A boolean representing whether or not to deploy External Secrets chart in the EKS cluster."
  default     = false
}

variable "karpenter_chart_verison" {
  type        = string
  description = "A string representing the version of the Karpenter Helm chart to deploy."
  default     = "0.35.2"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to assign for all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = ""
}

variable "wiz_admission_controller_mode" {
  type    = string
  default = "AUDIT"
  validation {
    condition     = contains(["AUDIT", "BLOCK"], var.wiz_admission_controller_mode)
    error_message = "Enforcement mode must either be 'AUDIT' or 'BLOCK'"
  }
}

variable "wiz_admission_controller_policies" {
  type    = list(string)
  default = []
}

variable "wiz_k8s_integration_client_id" {
  type    = string
  default = ""
}

variable "wiz_k8s_integration_client_secret" {
  type    = string
  default = ""
}

variable "wiz_namespace" {
  type    = string
  default = "wiz"
}

variable "wiz_sensor_pull_username" {
  type    = string
  default = ""
}

variable "wiz_sensor_pull_password" {
  type    = string
  default = ""
}

variable "wiz_use_wiz_admission_controller" {
  type    = bool
  default = false
}

variable "wiz_use_wiz_k8s_audit_logs" {
  type    = bool
  default = false
}

variable "wiz_use_wiz_sensor" {
  type    = bool
  default = false
}
