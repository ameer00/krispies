variable "credentials" { default = "~/credentials.json" }
variable "project" { default = "krispies-tf-admin" }
variable "region" { default = "us-central1" }

provider "google" {
 version     = "~> 1.15"
 credentials = "${file("${var.credentials}")}"
 project     = "${var.project}"
 region      = "${var.region}"
}
