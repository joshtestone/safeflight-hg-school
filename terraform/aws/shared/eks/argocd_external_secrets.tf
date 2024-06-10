module "external_secrets_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                             = "${var.cluster_name}-external-secrets"
  attach_external_secrets_policy        = true
  external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/*"]
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:*"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = local.tags
}

resource "helm_release" "external_secrets" {
  count      = var.deploy_external_secrets ? 1 : 0

  name       = "external-secrets"
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
          name: external-secrets-operator
          finalizers:
            - resources-finalizer.argocd.argoproj.io
        spec:
          project: default
          source:
            repoURL: https://charts.external-secrets.io
            targetRevision: 0.9.19 # make sure to change this to the version you need
            chart: external-secrets
            helm:
              values: |
                extraEnv:
                  - name: AWS_REGION
                    value: "${var.region}"
                  - name: LOG_LEVEL
                    value: "warn"
                  - name: POLLER_INTERVAL_MILLISECONDS
                    value: "30000"
                serviceAccount:
                  annotations:
                    "eks.amazonaws.com/role-arn": "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-external-secrets"
                  create: true
                  name: external-secrets
          destination:
            name: in-cluster
            namespace: external-secrets # you can use any namespace
          syncPolicy:
            automated:
              prune: false
              selfHeal: false
              allowEmpty: false
            syncOptions:
              - PrunePropagationPolicy=foreground
              - Replace=false
              - PruneLast=false
              - Validate=true
              - CreateNamespace=true
              - ApplyOutOfSyncOnly=false
              - ServerSideApply=true
              - RespectIgnoreDifferences=false
    EOF
  ]

  depends_on = [
    helm_release.argocd
  ]
}