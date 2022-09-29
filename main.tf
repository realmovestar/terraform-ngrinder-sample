terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.22.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "ngrinder-controller" {
  name         = "ngrinder/controller:latest"
  keep_locally = true
}

resource "docker_image" "ngrinder-agent" {
  name         = "ngrinder/agent:latest"
  keep_locally = true
}

resource "docker_container" "ngrinder-controller" {
  image = docker_image.ngrinder-controller.image_id
  name  = "ngrinder-controller"
  ports {
    internal = 80
    external = 80
  }
  volumes {
    host_path = "${abspath(path.root)}/controller-data"
    container_path = "/opt/ngrinder-controller"
  }
}

resource "docker_container" "ngrinder-agent-1" {
  image = docker_image.ngrinder-agent.image_id
  name  = "ngrinder-agent-1"
  host {
    host = "controller"
    ip   = docker_container.ngrinder-controller.ip_address
  }
}

resource "docker_container" "ngrinder-agent-2" {
  image = docker_image.ngrinder-agent.image_id
  name  = "ngrinder-agent-2"
  host {
    host = "controller"
    ip   = docker_container.ngrinder-controller.ip_address
  }
}
