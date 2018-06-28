// Project creation and billing assignment
variable "project_count" { default = "2" }
variable "subnet_count" { default = "10" }
variable "project" { default = "theplatform-terraform-admin" }
variable "credentials" { default = "~/.config/gcloud/terraform-admin.json" }
// variable "project_name" { default = "theplatform-tf" }
variable "billing_account" { default = "00CF06-C4A4BE-92FDD8" }
variable "org_id" { default = "689680127547" }
variable "region" { default = "us-central1" }
variable "vpc" { default = "snap" }

provider "google" {
 version 	 = "~> 1.15"
 credentials = "${file("${var.credentials}")}"
 project     = "${var.project}"
 region 	 = "${var.region}"
}

resource "random_id" "pid" {
  count       = "${var.project_count}"
  byte_length = "4"
}

// Create Host project
resource "google_project" "host" {
 name            = "theplatform-host-project"
 project_id      = "theplatform-host-${element(random_id.pid.*.hex, count.index)}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}

// Configure VPC in host project
resource "google_compute_network" "vpc" {
 name                    = "${var.vpc}"
 project				 = "${google_project.host.project_id}"
 auto_create_subnetworks = "false"
 depends_on = ["google_project_service.host", "google_compute_shared_vpc_service_project.service_projects", ]
}

// Configure subnets
variable "node_ip_cidr" { default = "192.168.0.0/16"}
variable "pod_ip_cidr" { default = "10.0.0.0/8" }
variable "svc1_ip_cidr" { default = "172.16.0.0/15" }
variable "svc2_ip_cidr" { default = "172.18.0.0/15" }
variable "svc3_ip_cidr" { default = "172.20.0.0/15" }
variable "svc4_ip_cidr" { default = "172.22.0.0/15" }

resource "google_compute_subnetwork" "subnet" {
 count              = "${var.subnet_count}"
 name               = "subnet-${count.index}"
 project            = "${google_project.host.project_id}"
 ip_cidr_range      = "${cidrsubnet(var.node_ip_cidr, 9, count.index)}"
 network            = "${var.vpc}"
 region             = "${var.region}"
 secondary_ip_range = {
      range_name    = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.pod_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc1-${replace(replace(cidrsubnet(var.svc1_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc1_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc2-${replace(replace(cidrsubnet(var.svc2_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc2_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc3-${replace(replace(cidrsubnet(var.svc3_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc3_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc4-${replace(replace(cidrsubnet(var.svc4_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc4_ip_cidr, 9, count.index)}"
  }
 depends_on = ["google_compute_network.vpc"]
}

resource "google_project" "project" {
 count			 = "${var.project_count}"
 name            = "theplatform-svc-${count.index+1}"
 project_id      = "theplatform-svc-${element(random_id.pid.*.hex, count.index)}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}


resource "google_project_service" "host" {
 project = "${google_project.host.project_id}"
 service = "compute.googleapis.com"
}

resource "google_project_service" "project" {
 count   = "${var.project_count}"
 project = "${element(google_project.project.*.project_id, count.index)}"
 service = "compute.googleapis.com"
}

// Enable shared VPC hosting in the host project.
resource "google_compute_shared_vpc_host_project" "host" {
  project    = "${google_project.host.project_id}"
  depends_on = ["google_project_service.host"]
}

// Enable shared VPC on service projects - explicitly depend on the host
// project enabling it, because enabling shared VPC will fail if the host project
//# is not yet hosting.
resource "google_compute_shared_vpc_service_project" "service_projects" {
  count			  = "${var.project_count}"
  host_project    = "${google_project.host.project_id}"
  service_project = "${element(google_project.project.*.project_id, count.index)}"

  depends_on = ["google_compute_shared_vpc_host_project.host",
    "google_project_service.project",
  ]
}

// Assign Kubernetes host Service Agent role to the terraform service account in the Host project
resource "google_project_iam_member" "host_service_agent" {
	project = "${google_project_service.host_project.project}"
	role    = "roles/container.hostServiceAgentUser"
	member  = "serviceAccount:service-${google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
	depends_on = ["google_project_service.service_project"]
}

// IAM for service project's default service account <proj_num>@cloudservices.gserviceaccount.com, use subnets 
// repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_cloud_services" {
    count		  = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:${google_project.project.0.number}@cloudservices.gserviceaccount.com"
}

// IAM for service project's default service account service-<proj_num>@container-engine-robot.iam.gserviceaccount.com 
// use subnets.  repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_gke_user" {
	count 	      = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:service-${google_project.project.0.number}@container-engine-robot.iam.gserviceaccount.com"
}


// Bunch of outputs
output "host_project_id" {
	value = "${google_project.host.project_id}"
}

output "project_id" {
 value = ["${google_project.project.*.project_id}"]
}

output "svc_project_numbers" {
	value = ["${google_project.project.*.number}"]
}
