variable "name" { default = "snap" }
variable "create-subs" { default = "false" }
variable "project" {}


// Configure VPC in host project
resource "google_compute_network" "vpc" {
 name                    = "${var.name}"
 project		             = "${var.project}"
 auto_create_subnetworks = "${var.create_subs}"
 depends_on 		         = ["google_project_service.host-compute", 
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
