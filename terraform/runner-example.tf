resource "kubernetes_deployment" "runner" {
  metadata {
    name = "runner-example"
    namespace = "actions-runner"
    labels = {
      app = "actions-runner"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "actions-runner"
      }
    }

    template {
      metadata {
        labels = {
          app = "actions-runner"
        }
      }

      spec {
        volume {
          name = "docker-certs"
          empty_dir {}
        }
        volume {
          name = "work"
          empty_dir {}
        }  
        container {
          image = "docker:dind"
          name  = "docker"

          volume_mount {
            mount_path = "/certs/server"
            name = "docker-certs"
          }

          volume_mount {
            mount_path = "/opt/_work"
            name = "work"
          }

          security_context {
            privileged = true
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
        container {
          image = "ghcr.io/nopp/actions-runner-groups-k8s:0.0.10"
          name  = "runner"

          env {
            name = "DOCKER_HOST"
            value = "localhost:2376"
          }

          env {
            name = "DOCKER_TLS_VERIFY"
            value = "1"
          }

          env {
            name = "ORGANIZATION_NAME"
            value = "yourOrgNameHeere"
          }
          
          env {
            name = "GROUP_NAME"
            value = "default"
          }

          env {
            name = "GITHUB_PAT"
            value_from {
              secret_key_ref {
                key = "pat"
                name = "github"  
              }         
            }
          }    

          volume_mount {
            mount_path = "/home/sre/.docker"
            name = "docker-certs"
          }

          volume_mount {
            mount_path = "/root/.docker"
            name = "docker-certs"
          }

          volume_mount {
            mount_path = "/github/home/.docker"
            name = "docker-certs"
          }

          volume_mount {
            mount_path = "/opt/_work"
            name = "work"
          }          

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
