variable "syno_ip" {
  description = "Synology ip address"
  type        = string
}
variable "username" {
  default = "admin"
}
variable "password" {
  description = "Syno user password"
  type        = string
  sensitive   = true
}
variable "public_key" {}
variable "homedir"{}
variable "envpath"{
  default = "PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin:/usr/local/sbin:/usr/local/bin"
}