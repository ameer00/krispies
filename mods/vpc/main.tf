variable "name" { default = "snap" }
variable "create_subs" { default = "false" }
variable "project" {}


// Configure VPC in host project
resource "google_compute_network" "vpc" {
 name                    = "${var.name}"
 project		               = "${var.project}"
 auto_create_subnetworks = "${var.create_subs}"
 depends_on 		           = ["google_project_service.host-compute", 
                            "google_project_service.host-container", 
                            ]
}

resource "google_project_service" "host-compute" {
 project = "${var.project}"
 service = "compute.googleapis.com"
}

resource "google_project_service" "host-container" {
 project = "${var.project}"
 service = "container.googleapis.com"
}

// Enable shared VPC hosting in the host project.
resource "google_compute_shared_vpc_host_project" "host" {
  project    = "${var.project}"
  depends_on = ["google_project_service.host-compute"]
}

output "project" {
	value = "${google_compute_shared_vpc_host_project.host.project}"
}

output "vpc_link" {
  value = "${google_compute_network.vpc.self_link}"
}
