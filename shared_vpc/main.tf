// Assume host and service projects are already created
// Using the prefix 06291 for projects i.e. host project is krispies06291-host-project and
// Service projects are krispies06291-svc-1 through svc-10
// project_count variable stores num of svc projects i.e. krispies06291-svc-[var.project_count]

// Project creation and billing assignment
variable "project_count" { default = "2" }
variable "service_project" { default = [ "885362682", "1028161978297", "808980461674", "1016788329490", "69246815672", "924830371865", "877760245336", "800171114423", "777888774563", "564266229360" ] }
variable "subnet_count" { default = "10" }
variable "project" { default = "krispies-tf-admin" }
variable "host_project" { default = "krispies06291-host-project" }
variable "credentials" { default = "~/.config/gcloud/terraform-admin.json" }
// variable "project_name" { default = "krispies-tf" }
variable "billing_account" { default = "00CF06-C4A4BE-92FDD8" }
variable "org_id" { default = "990456989270" }
variable "zone1" { default = "us-central1-a" }
variable "region" { default = "us-central1" }
variable "vpc" { default = "snap" }

provider "google" {
 version     = "~> 1.15"
 credentials = "${file("${var.credentials}")}"
 project     = "${var.project}"
 region      = "${var.region}"
}

/*
// Create Host project
resource "google_project" "host" {
 name            = "${var.host_project}"
 project_id      = "${var.host_project}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}
*/

// Configure VPC in host project
resource "google_compute_network" "vpc" {
 name                    = "${var.vpc}"
 project		 = "${var.host_project}"
 auto_create_subnetworks = "false"
 depends_on 		 = ["google_project_service.host", "google_compute_shared_vpc_service_project.service_projects", ]
}

// Configure subnets
variable "node_ip_cidr" { default = "192.168.0.0/16"}
variable "pod_ip_cidr"  { default = "10.0.0.0/8" }
variable "svc1_ip_cidr" { default = "172.16.0.0/15" }
variable "svc2_ip_cidr" { default = "172.18.0.0/15" }
variable "svc3_ip_cidr" { default = "172.20.0.0/15" }
variable "svc4_ip_cidr" { default = "172.22.0.0/15" }

resource "google_compute_subnetwork" "subnet" {
 count              = "${var.subnet_count}"
 name               = "subnet-${count.index}"
 project            = "${var.host_project}"
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

/*
// Service projects should already be created with prefix krispies06291-svc-[var.project_count]
resource "google_project" "project" {
 count		 = "${var.project_count}"
 name            = "krispies-svc-${count.index+1}"
 project_id      = "krispies-svc-${count.index+1}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}
*/

resource "google_project_service" "host" {
 project = "${var.host_project}"
 service = "compute.googleapis.com"
}

resource "google_project_service" "host-container" {
 project = "${var.host_project}"
 service = "container.googleapis.com"
}

resource "google_project_service" "project" {
 count   = "${var.project_count}"
 project = "krispies06291-svc-${count.index+1}"
// project = "${element(google_project.project.*.project_id, count.index)}"
 service = "compute.googleapis.com"
}

resource "google_project_service" "project-container" {
 count   = "${var.project_count}"
 project = "krispies06291-svc-${count.index+1}"
// project = "${element(google_project.project.*.project_id, count.index)}"
 service = "container.googleapis.com"
}

// Enable shared VPC hosting in the host project.
resource "google_compute_shared_vpc_host_project" "host" {
  project    = "${var.host_project}"
  depends_on = ["google_project_service.host"]
}

// Enable shared VPC on service projects - explicitly depend on the host
// project enabling it, because enabling shared VPC will fail if the host project
//# is not yet hosting.
resource "google_compute_shared_vpc_service_project" "service_projects" {
  count		  = "${var.project_count}"
  host_project    = "${var.host_project}"
  service_project = "krispies06291-svc-${count.index+1}"
  // service_project = "${element(google_project.project.*.project_id, count.index)}"

  depends_on = ["google_compute_shared_vpc_host_project.host",
    "google_project_service.project",
  ]
}


// Assign Kubernetes host Service Agent role to the terraform service account in the Host project
resource "google_project_iam_member" "host_service_agent" {
	count	   = "${var.project_count}"
	project    = "${google_project_service.host.project}"
	role       = "roles/container.hostServiceAgentUser"
	member     = "serviceAccount:service-${var.service_project[count.index]}@container-engine-robot.iam.gserviceaccount.com"
	depends_on = ["google_project_service.project"]
}

// IAM for service project's default service account <proj_num>@cloudservices.gserviceaccount.com, use subnets 
// repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_cloud_services" {
    count	      = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:${var.service_project[count.index]}@cloudservices.gserviceaccount.com"
        depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}

// IAM for service project's default service account service-<proj_num>@container-engine-robot.iam.gserviceaccount.com 
// use subnets.  repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_gke_user" {
	count	      = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:service-${var.service_project[count.index]}@container-engine-robot.iam.gserviceaccount.com"
	depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}

/*
// Create Cluster
resource "google_container_cluster" "shared_vpc_cluster" {
	count		   = 1
	name               = "cluster-${count.index}"
	zone               = "${var.zone1}"
	initial_node_count = 3
	project            = "krispies06291-svc-${count.index+1}"
	network    	   = "${google_compute_network.vpc.self_link}"
	subnetwork	   = "${element(google_compute_subnetwork.subnet.*.self_link, count.index)}"
	ip_allocation_policy {
        cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
        services_secondary_range_name = "svc1-${replace(replace(cidrsubnet(var.svc1_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
	}
	depends_on = [
		"google_project_iam_member.host_service_agent",
		"google_compute_subnetwork_iam_member.service_network_cloud_services",
		"google_compute_subnetwork_iam_member.service_network_gke_user",
		"google_compute_subnetwork.subnet",
		"google_project_service.project-container",
		"google_project_service.host-container",
	]
}
*/

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

output "shared_vpc_svc_projects" {
	value = ["${google_compute_shared_vpc_service_project.service_projects.*.service_project}"]
}
