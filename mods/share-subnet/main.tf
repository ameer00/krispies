variable "subnet_count" {}
variable "project" {}
variable "project_number" {}
variable "region" { default = "us-central1" }


// IAM for service project's default service account <proj_num>@cloudservices.gserviceaccount.com, use subnets
// repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_cloud_services" {
        count         = "${var.subnet_count}"
        project       = "${var.project}"
	region	      = "${var.region}"
        subnetwork    = "subnet-${count.index}"
        role          = "roles/compute.networkUser"
        member        = "serviceAccount:${var.project_number}@cloudservices.gserviceaccount.com"
//        depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}

// IAM for service project's default service account service-<proj_num>@container-engine-robot.iam.gserviceaccount.com
// use subnets.  repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_gke_user" {
        count         = "${var.subnet_count}"
        project       = "${var.project}"
	region	      = "${var.region}"
        subnetwork    = "subnet-${count.index}"
        role          = "roles/compute.networkUser"
        member        = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
//        depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}
