resource "random_id" "uniq" {
  byte_length = 4
}

resource "kubernetes_namespace" "wiz" {
  count = var.deploy_wiz ? 1 : 0

  metadata {
    name = var.wiz_namespace
  }
}

resource "helm_release" "wiz_k8s_integration_argocd" {
  count      = var.deploy_wiz ? 1 : 0

  name       = "wiz-k8s-argocd-application"
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
          name: wiz-k8s-integration
          namespace: ${kubernetes_namespace.argocd[count.index].id}
          finalizers:
          - resources-finalizer.argocd.argoproj.io
        spec:
          project: default
          source:
            repoURL: 'https://wiz-sec.github.io/charts'
            targetRevision: 0.*
            helm:
              values: |+
                global:
                  wizApiToken:
                    clientId: ${var.wiz_k8s_integration_client_id}
                    clientToken: ${var.wiz_k8s_integration_client_secret}

                wiz-admission-controller:
                  enabled: ${var.wiz_use_wiz_admission_controller}
                  webhook:
                    errorEnforcementMethod: ${var.wiz_admission_controller_mode}
                    policyEnforcementMethod: ${var.wiz_admission_controller_mode}

                  opaWebhook:
                    policies: ${jsonencode(var.wiz_admission_controller_policies)}

                  kubernetesAuditLogsWebhook:
                    enabled: ${var.wiz_use_wiz_k8s_audit_logs}

                wiz-kubernetes-connector:
                  enabled: true
                  broker:
                    enabled: false
                  autoCreateConnector:
                    connectorName: ${local.kubernetes_connector_name}
                    clusterFlavor: EKS
                    apiServerEndpoint: ${module.eks.cluster_endpoint}

                wiz-sensor:
                  enabled: ${var.wiz_use_wiz_sensor}
                  imagePullSecret:
                    username: ${var.wiz_sensor_pull_username}
                    password: ${var.wiz_sensor_pull_password}

            chart: wiz-kubernetes-integration
          destination:
            server: 'https://kubernetes.default.svc'
            namespace: ${kubernetes_namespace.wiz[count.index].id}
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
