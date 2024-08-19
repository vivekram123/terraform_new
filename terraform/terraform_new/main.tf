provider "google" {
  project = "practice1-430917"
  region  = "asia-south2"
}

# Fetch the existing VPC network
data "google_compute_network" "vpc_network" {
  name = "instance-test"
}

# Fetch the existing Subnetwork
data "google_compute_subnetwork" "subnet" {
  name   = "instance-test-pub"
  region = "asia-south2"
}

resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap"
  network = data.google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP IP range

  target_tags = ["iap-access"]
}

# Create a separate 10 GB persistent disk
resource "google_compute_disk" "extra_disk" {
  count = 3
  name  = "extra-disk-${count.index + 1}"
  size  = 10
  type  = "pd-ssd"
  zone  = "asia-south2-a"
}

resource "google_compute_instance" "vm_instance" {
  count        = 3
  name         = "my-vm-instance-${count.index + 1}"
  machine_type = "e2-small"
  zone         = "asia-south2-a"
  tags         = ["iap-access"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-noble-amd64-v20240806" # Ubuntu 22.04
    }
  }

  attached_disk {
    source = google_compute_disk.extra_disk[count.index].self_link
  }


  network_interface {
    network    = data.google_compute_network.vpc_network.self_link
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    access_config {
      // Ephemeral IP
    }
  }
}
