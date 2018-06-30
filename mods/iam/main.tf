variable "count" { default = "2" }
variable "host_project" {}
variable "svc_project_number" { type="list" }

// Assign Kubernetes host Service Agent role to the terraform service account in the Host project
resource "google_project_iam_member" "host_service_agent" {
	count	     = "${var.count}"
	project    = "${var.host_project}"
	role       = "roles/container.hostServiceAgentUser"
	member     = "serviceAccount:service-${element(var.svc_project_number, count.index)}@container-engine-robot.iam.gserviceaccount.com"
//	depends_on = ["google_project_service.project"]
}

output "count" {
  value = "${google_project_iam_member.host_service_agent.count}"
}

output "host_project" {
  value = "${google_project_iam_member.host_service_agent.0.project}"
}
