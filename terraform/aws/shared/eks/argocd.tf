resource "kubernetes_namespace" "argocd" {
  count = var.deploy_argocd ? 1 : 0
  
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  count = var.deploy_argocd ? 1 : 0

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd[count.index].id

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    kubectl_manifest.karpenter_node_pool
  ]
}
