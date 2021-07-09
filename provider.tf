//Creating Firewall for First VPC Network
	resource "google_compute_firewall" "firewall1" {
	  name    = "wp-firewall"
	  network = google_compute_network.vpc_network1.name
	

	  allow {
	    protocol = "icmp"
	  }
	

	  allow {
	    protocol = "tcp"
	    ports    = ["80", "8080"]
	  }
	

	  source_tags = ["wp", "wordpress"]
	

	  depends_on = [
	    google_compute_network.vpc_network1
	  ]
	}
	

	//Creating Second VPC Network
	resource "google_compute_network" "vpc_network2" {
	  name        = "prod-db-env"
	  description = "VPC Network For dataBase"
	  project     = var.project_id
	  auto_create_subnetworks = false
	}
	

	//Creating Network For Second VPC
	resource "google_compute_subnetwork" "subnetwork2" {
	  name          = "db-subnet"
	  ip_cidr_range = "10.4.0.0/16"
	  project       = var.project_id
	  region        = var.region2
	  network       = google_compute_network.vpc_network2.id
	

	  depends_on = [
	    google_compute_network.vpc_network2
	  ]
	}
