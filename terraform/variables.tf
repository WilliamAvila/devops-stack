variable "context" {
  type      = string
  sensitive = true
  default   = "minikube"
}
variable "namespace" {
  type      = string
  sensitive = true
  default   = "gowebservice"
}

variable "service" {
  type      = string
  sensitive = true
  default   = "webservice"
}

variable "dbnamespace" {
  type      = string
  sensitive = true
  default   = "mysqldatabase"
}

variable "dbservice" {
  type      = string
  sensitive = true
  default   = "db"
}

variable "dbname" {
  type      = string
  sensitive = true
  default   = "blog"
}

variable "dbuser" {
  type      = string
  sensitive = true
  default   = "user"
}

variable "dbpassword" {
  type      = string
  sensitive = true
  default   = "password"
}

