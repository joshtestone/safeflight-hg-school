locals {
  cluster_admins = length(var.cluster_admins) > 0 ? var.cluster_admins : [data.aws_iam_session_context.current.issuer_arn]
  cluster_admin_access_entries = {
    for i, user in local.cluster_admins :
    "cluster_admin_${i + 1}" => {
      principal_arn = "${user}"
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.id}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  kubernetes_connector_name = "${var.cluster_name}-connector-${random_id.uniq.hex}"

  tags = {
    Terraform = "true"
    Workspace = "s3://457661787930-terraform-backend/terraform/aws/shared/eks/${terraform.workspace}"
  }
}
