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
variable "count" { default = "10" }
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
      range_name    = "pod-${replace(cidrhost(var.pod_ip_cidr, 2), ".", "-")}"
      ip_cidr_range = "${cidrsubnet(var.pod_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc1-${replace(cidrhost(var.svc1_ip_cidr, 2), ".", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc1_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc2-${replace(cidrhost(var.svc2_ip_cidr, 2), ".", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc2_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc3-${replace(cidrhost(var.svc3_ip_cidr, 2), ".", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc3_ip_cidr, 9, count.index)}"
  }
 secondary_ip_range = {
      range_name    = "svc4-${replace(cidrhost(var.svc4_ip_cidr, 2), ".", "-")}"
      ip_cidr_range = "${cidrsubnet(var.svc4_ip_cidr, 9, count.index)}"
  }
 depends_on = ["google_compute_network.vpc"]
}
