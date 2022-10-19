terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "ssh://${var.username}@${var.docker_remote_ip}"
}

resource "docker_image" "sonarr" {
  name = "linuxserver/sonarr:latest"
}

locals {
  envs = { for tuple in regexall("(.*?)=(.*)\r", file("../../.env")) : tuple[0] => tuple[1] }
  env_sonarr = { for tuple in regexall("(.*?)=(.*)\r", file(".sonarr")) : tuple[0] => tuple[1] }
}


resource "docker_container" "sonarr" {
  name  = "sonarr"
  image = docker_image.sonarr.name 
  remove_volumes = false
  network_mode = "host"
  restart = "always"
  env = [
    "TZ=${local.envs["TIMEZONE"]}",
    "PGID=${local.envs["PGID"]}",
    "PUID=${local.envs["PUID"]}"
  ]

  volumes {
    host_path = local.env_sonarr["sonarr_host_config"]
    container_path = "/config"
  }

  volumes {
    host_path  = local.env_sonarr["sonarr_host_media"]
    container_path = local.env_sonarr["sonarr_container_media"]
  }

  volumes { 
    host_path  = "/${local.envs["trans_download"]}"
    container_path = "/${local.envs["container_downloads"]}"
  }
}

