terraform {
 backend "gcs" {
   bucket  = "theplatform-terraform-admin"
   prefix    = "/terraform.tfstate"
   project = "theplatform-terraform-admin"
 }
}
