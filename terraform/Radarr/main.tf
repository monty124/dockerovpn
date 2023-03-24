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

resource "docker_image" "radarr" {
  name = "linuxserver/radarr:latest"
}

locals {
  envs = { for tuple in regexall("(.*?)=(.*)\r", file("../../.env")) : tuple[0] => tuple[1] }
  env_radarr = { for tuple in regexall("(.*?)=(.*)\r", file(".radarr")) : tuple[0] => tuple[1] }
}


resource "docker_container" "radarr" {
  name  = "radarr"
  image = docker_image.radarr.name 
  remove_volumes = false
  network_mode = "host"
  restart = "always"
  env = [
    "TZ=${local.envs["TIMEZONE"]}",
    "PGID=${local.envs["PGID"]}",
    "PUID=${local.envs["PUID"]}"
  ]

  volumes {
    host_path = local.env_radarr["radarr_host_config"]
    container_path = "/config"
  }

  volumes {
    host_path  = local.env_radarr["radarr_host_media"]
    container_path = local.env_radarr["radarr_container_media"]
  }

  volumes { 
    host_path  = "/${local.envs["trans_download"]}"
    container_path = "/${local.envs["container_downloads"]}"
  }
}

