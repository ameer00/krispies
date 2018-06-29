variable "host_project" { default = "krispies1000-host-project" }
variable "billing_account" { default = "00CF06-C4A4BE-92FDD8" }
variable "org_id" { default = "990456989270" }

// Create Host project
resource "google_project" "host" {
 name            = "${var.host_project}"
 project_id      = "${var.host_project}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
 auto_create_network = "false"
}

output "project_id" {
	value = "${google_project.host.project_id}"
}
