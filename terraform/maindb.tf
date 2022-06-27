resource "kubernetes_manifest" "namespace_mysqldatabase" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "mysqldatabase"
    }
  }
}
resource "kubernetes_manifest" "persistentvolumeclaim_mysqldatabase_mysql_pvc" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "PersistentVolumeClaim"
    "metadata" = {
      "name"      = "mysql-pvc"
      "namespace" = var.dbnamespace
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "25Gi"
        }
      }
      "storageClassName" = "standard"
    }
  }
  depends_on = [
    kubernetes_manifest.namespace_mysqldatabase
  ]
}

resource "kubernetes_manifest" "configmap_mysqldatabase_mysql_initdb_config" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "init.sql" = <<-EOT
      CREATE DATABASE IF NOT EXISTS blog;
      USE blog;
      CREATE TABLE blog_posts (ID int(11), Title varchar(50), PostText varchar(225), Date date);
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "mysql-initdb-config"
      "namespace" = var.dbnamespace
    }
  }
  depends_on = [
    kubernetes_manifest.namespace_mysqldatabase
  ]
}

resource "kubernetes_manifest" "secret_mysqldatabase_mysql_password" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "rootpassword" = "cGFzc3dvcmQK"
    }
    "kind" = "Secret"
    "metadata" = {
      "name"              = "mysql-password"
      "namespace"         = var.dbnamespace
    }
  }  
  depends_on = [
    kubernetes_manifest.namespace_mysqldatabase
  ]
}

resource "kubernetes_manifest" "service_mysqldatabase_db" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = var.dbservice
      "namespace" = var.dbnamespace
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 3306
          "targetPort" = 3306
        },
      ]
      "selector" = {
        "app" = var.dbservice
      }
    }
  }  
  depends_on = [
    kubernetes_manifest.deployment_mysqldatabase_db
  ]
}

