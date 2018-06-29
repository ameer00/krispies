variable "count" { default = "2" }
variable "host_project" {}
variable "svc_project_number" {}

// Assign Kubernetes host Service Agent role to the terraform service account in the Host project
resource "google_project_iam_member" "host_service_agent" {
	count	     = "${var.count}"
	project    = "${var.host_project}"
	role       = "roles/container.hostServiceAgentUser"
	member     = "serviceAccount:service-${element(svc_project_number, count.index)}@container-engine-robot.iam.gserviceaccount.com"
//	depends_on = ["google_project_service.project"]
}

/*
// IAM for service project's default service account <proj_num>@cloudservices.gserviceaccount.com, use subnets 
// repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_cloud_services" {
    count	      = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:${google_project.project.0.number}@cloudservices.gserviceaccount.com"
        depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}

// IAM for service project's default service account service-<proj_num>@container-engine-robot.iam.gserviceaccount.com 
// use subnets.  repeat for multiple service projects and replace the .0.number field
resource "google_compute_subnetwork_iam_member" "service_network_gke_user" {
	count	      = "${var.subnet_count}"
	project       = "${google_compute_shared_vpc_host_project.host.project}"
	subnetwork    = "subnet-${count.index}"
	role          = "roles/compute.networkUser"
	member        = "serviceAccount:service-${google_project.project.0.number}@container-engine-robot.iam.gserviceaccount.com"
	depends_on    = ["google_compute_shared_vpc_service_project.service_projects"]
}
*/
