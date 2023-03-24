resource "null_resource" "enable_remote_docker" {
  connection {
    type     = "ssh"
    user     = var.username
    password = var.password
    host     = var.syno_ip
    script_path = "${var.homedir}/terraform_%RAND%.sh"
  }



provisioner "remote-exec" {
    inline = [
     #SET Public Key
    "mkdir ${var.homedir}/.ssh",
    "chmod 700 ${var.homedir}/.ssh",
    "echo ${var.public_key} >> ${var.homedir}/.ssh/authorized_keys",
    "chmod 640 ${var.homedir}/.ssh/authorized_keys",
    "echo ${var.password} | sudo -S sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment yes/g' /etc/ssh/sshd_config",
    "echo ${var.envpath} >> .ssh/environment",
    "echo ${var.password} | sudo -S synogroup --add docker ${var.username}",
    "echo ${var.password} | sudo -S chown root:docker /var/run/docker.sock",
    "rm -rf ${var.homedir}/*",
    "echo ${var.password} | sudo -S systemctl restart sshd"
    ]
}

}