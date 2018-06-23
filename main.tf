// Variables for project
variable "region" { default = "us-central1" }
variable "project" { default = "krispies-crackle" }
variable "credentials" { default = "credentials.json" }

// Configure the Google Cloud provider
provider "google" {
 version = "~> 1.13"
 credentials = "${file("${var.credentials}")}"
 project     = "${var.project}"
 region      = "${var.region}"
}

// Variables for VPC
variable "vpc" { default = "snap" }

// Configure VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.vpc}"
 auto_create_subnetworks = "false"
}

// Configure subnets
variable "count" { default = "3" }
variable "node_ip_cidr" { default = "192.168.0.0/16"}
variable "pod_ip_cidr" { default = "10.0.0.0/8" }
variable "svc1_ip_cidr" { default = "172.16.0.0/15" }
variable "svc2_ip_cidr" { default = "172.18.0.0/15" }
variable "svc3_ip_cidr" { default = "172.20.0.0/15" }
variable "svc4_ip_cidr" { default = "172.22.0.0/15" }

resource "google_compute_subnetwork" "subnet" {
 count              = "${var.count}"
 name               = "subnet-${count.index}"
 project            = "${var.project}"
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
 
 
// Variables for GKE
variable "zone" { default = "us-central1-f" }
variable "master1_ip_cidr" { default = "172.24.0.0/19" } 
variable "master2_ip_cidr" { default = "172.25.0.0/19" }
variable "master3_ip_cidr" { default = "172.26.0.0/19" }
variable "master4_ip_cidr" { default = "172.27.0.0/19" }
 
// Create GKE Clusters 1 of 4
resource "google_container_cluster" "gke-0" {
  count                   = "${var.count}"
  name                    = "gke1-${var.count}"
  zone                    = "${var.zone}"
  network                 = "${var.vpc}"
  subnetwork              = "subnet-${count.index}"
  initial_node_count      = 31
  private_cluster         = "true"
  master_ipv4_cidr_block  = "${cidrsubnet(var.master1_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc1-${replace(replace(cidrsubnet(var.svc1_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
  depends_on = ["google_compute_subnetwork.subnet"]
}
 
// Create GKE Clusters 2 of 4
resource "google_container_cluster" "gke-1" {
  count                   = "${var.count}"
  name                    = "gke2-${var.count}"
  zone                    = "${var.zone}"
  network                 = "${var.vpc}"
  subnetwork              = "subnet-${count.index}"
  initial_node_count      = 31
  private_cluster         = "true"
  master_ipv4_cidr_block  = "${cidrsubnet(var.master2_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc2-${replace(replace(cidrsubnet(var.svc2_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
  depends_on = ["google_compute_subnetwork.subnet"]
}
 
// Create GKE Clusters 3 of 4
resource "google_container_cluster" "gke-2" {
  count                   = "${var.count}"
  name                    = "gke3-${var.count}"
  zone                    = "${var.zone}"
  network                 = "${var.vpc}"
  subnetwork              = "subnet-${count.index}"
  initial_node_count      = 31
  private_cluster         = "true"
  master_ipv4_cidr_block  = "${cidrsubnet(var.master3_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc3-${replace(replace(cidrsubnet(var.svc3_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
  depends_on = ["google_compute_subnetwork.subnet"]
}
 
// Create GKE Clusters 4 of 4
resource "google_container_cluster" "gke-3" {
  count                   = "${var.count}"
  name                    = "gke4-${var.count}"
  zone                    = "${var.zone}"
  network                 = "${var.vpc}"
  subnetwork              = "subnet-${count.index}"
  initial_node_count      = 31
  private_cluster         = "true"
  master_ipv4_cidr_block  = "${cidrsubnet(var.master4_ip_cidr, 9, count.index)}"
  ip_allocation_policy    = {
   cluster_secondary_range_name  = "pod-${replace(replace(cidrsubnet(var.pod_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   services_secondary_range_name = "svc4-${replace(replace(cidrsubnet(var.svc4_ip_cidr, 9, count.index), ".", "-"), "/", "-")}"
   }
  depends_on = ["google_compute_subnetwork.subnet"]
}
