##################
## Atlantis POD ##
##################
locals {
  atlantis-manager-role = "${var.account_id}-${var.cluster_name}-atlantis-manager"
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "atlantis_manager" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/*-atlantis-deployer"]
  }
}

resource "aws_iam_policy" "atlantis_manager" {
  name        = "atlantis-manager"
  description = "Allow atlantis to assume the atlantis-deployer roles for various clusters"
  policy      = join("", data.aws_iam_policy_document.atlantis_manager.*.json)
}

resource "aws_iam_role_policy_attachment" "atlantis_manager" {
  role       = module.atlantis_manager_role.iam_role_name
  policy_arn = join("", aws_iam_policy.atlantis_manager.*.arn)
}

data "aws_iam_policy_document" "secrets_manager" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    effect    = "Allow"
    resources = ["arn:aws:secretsmanager:*:*:secret:*atlantis*"]
  }
}

resource "aws_iam_policy" "secrets_manager" {
  name        = "secrets-manager"
  description = "Allow atlantis to get secrets from the atlantis* secrets"
  policy      = join("", data.aws_iam_policy_document.secrets_manager.*.json)
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = module.atlantis_manager_role.iam_role_name
  policy_arn = join("", aws_iam_policy.secrets_manager.*.arn)
}

module "atlantis_manager_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.1"

  # required inputs
  role_name = local.atlantis-manager-role

  # if this is the cluster where atlantis will be deployed, create this role
  create_role      = true
  role_description = "Allows Atlantis to manage terraform resources"
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:atlantis:atlantis",
  ]
  provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags         = local.tags
}

resource "helm_release" "atlantis" {
  count      = var.deploy_atlantis ? 1 : 0

  name       = "atlantis"
  namespace  = kubernetes_namespace.argocd[count.index].id
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: argoproj.io/v1alpha1
        kind: Application
        metadata:
          name: atlantis
          finalizers:
            - resources-finalizer.argocd.argoproj.io
        spec:
          project: default
          source:
            repoURL: https://github.com/jmorgan415/safeflight-hg-school
            targetRevision: main
            path: argocd/charts/atlantis
            helm:
              values: |
                atlantis:
                  serviceAccount:
                    annotations:
                      "eks.amazonaws.com/role-arn": "arn:aws:iam::${var.account_id}:role/${var.account_id}-${var.cluster_name}-atlantis-manager"
                    create: true
                    name: atlantis
          destination:
            name: in-cluster
            namespace: atlantis # you can use any namespace
          syncPolicy:
            automated:
              prune: true
              selfHeal: true
            syncOptions:
              - CreateNamespace=true
              - PruneLast=true
              - RespectIgnoreDifferences=true
              - ServerSideApply=true
    EOF
  ]

  depends_on = [
    helm_release.argocd
  ]
}
