terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.context
}

resource "kubernetes_namespace" "mynamespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_manifest" "deployment_webserver" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = var.service
      "namespace" = var.namespace
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = var.service
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = var.service
          }
        }
        "spec" = {
          "containers" = [
            {
              "image"           = "webserver:31E2B07"
              "imagePullPolicy" = "IfNotPresent"
              "lifecycle" = {
                "preStop" = {
                  "exec" = {
                    "command" = [
                      "/bin/sh",
                      "-c",
                      "echo \"Last Date executed\" `date`",
                    ]
                  }
                }
              }
              "livenessProbe" = {
                "exec" = {
                  "command" = [
                    "/bin/sh",
                    "-c",
                    "wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1",
                  ]
                }
                "failureThreshold" = 5
                "timeoutSeconds"   = 5
              }
              "name" = var.service
              "ports" = [
                {
                  "containerPort" = 8080
                },
              ]
            },
          ]
          "initContainers" = [
            {
              "command" = [
                "sh",
                "-c",
                "echo Preparing webservice to start running in 30 seconds! && sleep 30",
              ]
              "image" = "busybox:1.28"
              "name"  = "init-webservice"
            },
          ]
          "restartPolicy" = "Always"
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.service_mysqldatabase_db
  ]
}
resource "kubernetes_manifest" "service_webserver" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = var.service
      "namespace" = var.namespace
    }
    "spec" = {
      "ports" = [
        {
          "name"       = "8080"
          "port"       = 8080
          "targetPort" = 8080
        },
      ]
      "selector" = {
        "app" = var.service
      }
       "type" = "LoadBalancer"
    }
  }
  depends_on = [
    kubernetes_namespace.mynamespace
  ]
}
