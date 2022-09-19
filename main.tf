#terraform init -var-file="production.tfvars"
#terraform plan -var-file="production.tfvars"
#terraform apply -var-file="production.tfvars"
#terraform destroy -var-file="production.tfvars"

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {  
  token = var.api_token
  
}

resource "digitalocean_project" "thetest" {
  name        = "name project"
  description = "Description"
  purpose     = "Description purposes"
  environment = "Development"
  resources   = digitalocean_droplet.web[*].urn
}

# Create a new Web Droplet in the nyc1 region
resource "digitalocean_droplet" "web" {
  image  = var.image
  name   = "coretest"
  region = var.region  
  size = var.instance_type
  user_data = "${file("userdata.yaml")}"
  ssh_keys = [var.ssh_keys]  
}

resource "digitalocean_firewall" "web" {
  name = "only-ssh-http-and-https"

  droplet_ids = [digitalocean_droplet.web.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
