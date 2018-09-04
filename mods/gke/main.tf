variable "count" { default = "1" }
variable "svc_count" {}
variable "zone1" { default = "us-central1-b" }
variable "zone2" { default = "us-central1-f" }
variable "project" { type = "list" }
variable "vpc" { default = "snap" }
variable "subnet" { type = "list" }
variable "pod_ip_cidr" { default = "10.0.0.0/8" }
variable "svc1_ip_cidr" { default = "172.16.0.0/15" }
variable "svc2_ip_cidr" { default = "172.18.0.0/15" }
variable "svc3_ip_cidr" { default = "172.20.0.0/15" }
variable "svc4_ip_cidr" { default = "172.22.0.0/15" }

// Create GKE Clusters 1 of 4
resource "google_container_cluster" "gke-0" {
  count                   = "${var.count}"
  name                    = "gke-subnet-${count.index}-0"
  zone                    = "${var.zone1}"
  project		  = "${element(var.project, var.svc_count)}"
  network                 = "${var.vpc}"
  subnetwork              = "${element(var.subnet, count.index)}"
  initial_node_count      = 31
//  private_cluster         = "true"
//  master_ipv4_cidr_block  = "${cidrsubnet(var.master1_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc1-${replace(replace(cidrsubnet(var.svc1_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
//  depends_on = ["google_compute_subnetwork.subnet"]
}

// Create GKE Clusters 2 of 4
resource "google_container_cluster" "gke-1" {
  count                   = "${var.count}"
  name                    = "gke-subnet-${count.index}-1"
  zone                    = "${var.zone2}"
  project		  = "${element(var.project, var.svc_count)}"
  network                 = "${var.vpc}"
  subnetwork              = "${element(var.subnet, count.index)}"
  initial_node_count      = 31
//  private_cluster         = "true"
//  master_ipv4_cidr_block  = "${cidrsubnet(var.master2_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc2-${replace(replace(cidrsubnet(var.svc2_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
//  depends_on = ["google_compute_subnetwork.subnet"]
}

// Create GKE Clusters 3 of 4
resource "google_container_cluster" "gke-2" {
  count                   = "${var.count}"
  name                    = "gke-subnet-${count.index}-2"
  zone                    = "${var.zone1}"
  project		  = "${element(var.project, var.svc_count)}"
  network                 = "${var.vpc}"
  subnetwork              = "${element(var.subnet, count.index)}"
  initial_node_count      = 31
//  private_cluster         = "true"
//  master_ipv4_cidr_block  = "${cidrsubnet(var.master3_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc3-${replace(replace(cidrsubnet(var.svc3_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
//  depends_on = ["google_compute_subnetwork.subnet"]
}

// Create GKE Clusters 4 of 4
resource "google_container_cluster" "gke-3" {
  count                   = "${var.count}"
  name                    = "gke-subnet-${count.index}-3"
  zone                    = "${var.zone2}"
  project		  = "${element(var.project, var.svc_count)}"
  network                 = "${var.vpc}"
  subnetwork              = "${element(var.subnet, count.index)}"
  initial_node_count      = 31
//  private_cluster         = "true"
//  master_ipv4_cidr_block  = "${cidrsubnet(var.master4_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc4-${replace(replace(cidrsubnet(var.svc4_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
//  depends_on = ["google_compute_subnetwork.subnet"]
}

/*
// Create Cluster
resource "google_container_cluster" "shared_vpc_cluster" {
	count		   = "${var.count}"
	name               = "cluster-${count.index}"
	zone               = "${var.zone1}"
	initial_node_count = 3
	project            = "${element(var.project, 0)}"
	network    	   = "${var.vpc}"
	subnetwork	   = "${element(google_compute_subnetwork.subnet.*.self_link, count.index)}"
	ip_allocation_policy {
        cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
        services_secondary_range_name = "svc1-${replace(replace(cidrsubnet(var.svc1_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
	}
//	depends_on = [
//		"google_project_iam_member.host_service_agent",
//		"google_compute_subnetwork_iam_member.service_network_cloud_services",
//		"google_compute_subnetwork_iam_member.service_network_gke_user",
//		"google_compute_subnetwork.subnet",
//		"google_project_service.project-container",
//		"google_project_service.host-container",
//	]
}
*/
