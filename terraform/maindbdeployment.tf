resource "kubernetes_manifest" "deployment_mysqldatabase_db" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = var.dbservice
      "namespace" = var.dbnamespace
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = var.dbservice
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = var.dbservice
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "MYSQL_DATABASE"
                  "value" = var.dbname
                },
                {
                  "name" = "MYSQL_PASSWORD"
                  "value" = var.dbpassword
                },
                {
                  "name" = "MYSQL_ROOT_PASSWORD"
                  "value" = var.dbpassword
                },
                {
                  "name"  = "MYSQL_USER"
                  "value" = var.dbuser
                },
              ]
              "image" = "mysql:oracle"
              "livenessProbe" = {
                "exec" = {
                  "command" = [
                    "mysqladmin",
                    "-uroot",
                    "-p$MYSQL_ROOT_PASSWORD",
                    "ping",
                  ]
                }
                "failureThreshold" = 5
                "timeoutSeconds"   = 5
              }
              "name" = var.dbservice
              "ports" = [
                {
                  "containerPort" = 3306
                },
              ]
              "volumeMounts" = [
                {
                  "mountPath" = "/docker-entrypoint-initdb.d"
                  "name"      = "mysql-initdb"
                },
                {
                  "mountPath" = "/var/lib/mysql"
                  "name"      = "mysql-storage"
                },
              ]
            },
          ]
          "restartPolicy" = "Always"
          "volumes" = [
            {
              "name" = "mysql-storage"
              "persistentVolumeClaim" = {
                "claimName" = "mysql-pvc"
              }
            },
            {
              "configMap" = {
                "name" = "mysql-initdb-config"
              }
              "name" = "mysql-initdb"
            },
          ]
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.secret_mysqldatabase_mysql_password,
    kubernetes_manifest.persistentvolumeclaim_mysqldatabase_mysql_pvc,
    kubernetes_manifest.configmap_mysqldatabase_mysql_initdb_config
  ]
}
