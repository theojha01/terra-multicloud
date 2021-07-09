resource "google_sql_database" "sql_db" {
	  name     = var.database
	  instance = google_sql_database_instance.sqldb_Instance.name
	

	  depends_on = [
	    google_sql_database_instance.sqldb_Instance
	  ]  
	}
	

	//Creating SQL Database User
	resource "google_sql_user" "dbUser" {
	  name     = var.db_user
	  instance = google_sql_database_instance.sqldb_Instance.name
	  password = var.db_user_pass
	

	  depends_on = [
	    google_sql_database_instance.sqldb_Instance
	  ]
	}
	

	//Creating Container Cluster
	resource "google_container_cluster" "gke_cluster1" {
	  name     = "my-cluster"
	  description = "My GKE Cluster"
	  project = var.project_id
	  location = var.region1
	  network = google_compute_network.vpc_network1.name
	  subnetwork = google_compute_subnetwork.subnetwork1.name
	  remove_default_node_pool = true
	  initial_node_count       = 1
	

	  depends_on = [
	    google_compute_subnetwork.subnetwork1
	  ]
	}
	

	//Creating Node Pool For Container Cluster
	resource "google_container_node_pool" "nodepool1" {
	  name       = "my-node-pool"
	  project    = var.project_id
	  location   = var.region1
	  cluster    = google_container_cluster.gke_cluster1.name
	  node_count = 1
	

	  node_config {
	    preemptible  = true
	    machine_type = "e2-micro"
	  }
	

	  autoscaling {
	    min_node_count = 1
	    max_node_count = 3
	  }
	

	  depends_on = [
	    google_container_cluster.gke_cluster1
	  ]
	}
	

	//Set Current Project in gcloud SDK
	resource "null_resource" "set_gcloud_project" {
	  provisioner "local-exec" {
	    command = "gcloud config set project ${var.project_id}"
	  }  
	}
	

	//Configure Kubectl with Our GCP K8s Cluster
	resource "null_resource" "configure_kubectl" {
	  provisioner "local-exec" {
	    command = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster1.name} --region ${google_container_cluster.gke_cluster1.location} --project ${google_container_cluster.gke_cluster1.project}"
	  }  
	

	  depends_on = [
	    null_resource.set_gcloud_project,
	    google_container_cluster.gke_cluster1
	  ]
	}
	

	//WordPress Deployment
	resource "kubernetes_deployment" "wp-dep" {
	  metadata {
	    name   = "wp-dep"
	    labels = {
	      env     = "Production"
	    }
	  }
	

	  spec {
	    replicas = 1
	    selector {
	      match_labels = {
	        pod     = "wp"
	        env     = "Production"
	      }
	    }
	

	    template {
	      metadata {
	        labels = {
	          pod     = "wp"
	          env     = "Production"
	        }
	      }
	

	      spec {
	        container {
	          image = "wordpress"
	          name  = "wp-container"
	

	          env {
	            name  = "WORDPRESS_DB_HOST"
	            value = "${google_sql_database_instance.sqldb_Instance.ip_address.0.ip_address}"
	          }
	          env {
	            name  = "WORDPRESS_DB_USER"
	            value = var.db_user
	          }
	          env {
	            name  = "WORDPRESS_DB_PASSWORD"
	            value = var.db_user_pass
	          }
	          env{
	            name  = "WORDPRESS_DB_NAME"
	            value = var.database
	          }
	          env{
	            name  = "WORDPRESS_TABLE_PREFIX"
	            value = "wp_"
	          }
	

	          port {
	            container_port = 80
	          }
	        }
	      }
	    }
	  }
	

	  depends_on = [
	    null_resource.set_gcloud_project,
	    google_container_cluster.gke_cluster1,
	    google_container_node_pool.nodepool1,
	    null_resource.configure_kubectl
	  ]
	}
	

	//Creating LoadBalancer Service
	resource "kubernetes_service" "wpService" {
	  metadata {
	    name   = "wp-svc"
	    labels = {
	      env     = "Production" 
	    }
	  }  
	

	  spec {
	    type     = "LoadBalancer"
	    selector = {
	      pod = "${kubernetes_deployment.wp-dep.spec.0.selector.0.match_labels.pod}"
	    }
	

	    port {
	      name = "wp-port"
	      port = 80
	    }
	  }
	

	  depends_on = [
	    kubernetes_deployment.wp-dep,
	   ]
    }
