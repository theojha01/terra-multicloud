//Creating Firewall for Second VPC Network
	resource "google_compute_firewall" "firewall2" {
	  name    = "db-firewall"
	  network = google_compute_network.vpc_network2.name
	

	  allow {
	    protocol = "tcp"
	    ports    = ["80", "8080", "3306"]
	  }
	

	  source_tags = ["db", "database"]
	

	  depends_on = [
	    google_compute_network.vpc_network2
	  ]
	}
	

	//VPC Network Peering1 
	resource "google_compute_network_peering" "peering1" {
	  name         = "wp-to-db"
	  network      = google_compute_network.vpc_network1.id
	  peer_network = google_compute_network.vpc_network2.id
	

	  depends_on = [
	    google_compute_network.vpc_network1,
	    google_compute_network.vpc_network2
	  ]
	}
	

	//VPC Network Peering2
	resource "google_compute_network_peering" "peering2" {
	  name         = "db-to-wp"
	  network      = google_compute_network.vpc_network2.id
	  peer_network = google_compute_network.vpc_network1.id
	

	  depends_on = [
	    google_compute_network.vpc_network1,
	    google_compute_network.vpc_network2
	  ]
    }
