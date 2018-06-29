variable "count" { default = "2" }
variable "billing_account" { default = "00CF06-C4A4BE-92FDD8" }
variable "org_id" { default = "990456989270" }
variable "create_subs" { default = "false" }
variable "host_project" {}

resource "google_project" "project" {
 count		       = "${var.count}"
 name            = "krispies1100-svc-${count.index+1}"
 project_id      = "krispies1100-svc-${count.index+1}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
 auto_create_network = "${var.create_subs}"
}

resource "google_project_service" "project" {
 count   = "${var.count}"
 project = "${element(google_project.project.*.project_id, count.index)}"
 service = "compute.googleapis.com"
}

resource "google_project_service" "project-container" {
 count   = "${var.count}"
 project = "${element(google_project.project.*.project_id, count.index)}"
 service = "container.googleapis.com"
}

// Enable shared VPC on service projects - explicitly depend on the host
// project enabling it, because enabling shared VPC will fail if the host project
//# is not yet hosting.
resource "google_compute_shared_vpc_service_project" "service_projects" {
  count		         = "${var.count}"
  host_project    = "${var.host_project}"
  service_project = "${element(google_project.project.*.project_id, count.index)}"

//  depends_on = ["google_compute_shared_vpc_host_project.host",
//    "google_project_service.project",
//  ]
}

output "host_project" {
	value = "${google_compute_shared_vpc_service_project.service_projects.host_project}"
}

output "svc_project_number" {
	value = ["${google_project.project.*.number}"]
}
