provider "google" {
  project = "practice1-430917"
  region  = "asia-south2"
}

data "google_compute_network" "vpc_network" {
  name = "instance-test"
}

# Fetch the existing Subnetwork
data "google_compute_subnetwork" "subnet" {
  name   = "instance-test-pub"
  region = "asia-south2"
}

resource "google_compute_instance" "vm_instance" {
  count        = 4
  name         = "my-vm-instance-${count.index + 1}"
  machine_type = "e2-small"
  zone         = "asia-south2-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-noble-amd64-v20240806"
    }
  }

  network_interface {
    network    = data.google_compute_network.vpc_network.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    access_config {
      // Ephemeral IP
    }
  }
}
