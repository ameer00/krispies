terraform {
 backend "gcs" {
   bucket  = "krispies-tf-admin"
   prefix    = "/terraform.tfstate"
   project = "krispies-tf-admin"
 }
}
