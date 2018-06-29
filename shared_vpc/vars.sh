# Tutorial: https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
# Change org_id, billing_id to match your org/bill
# TF_ADMIN should be the terraform host project, which can create other projects
# TF_CREDS is the location of the service account JSON key file
 
export TF_VAR_org_id=990456989270
export TF_VAR_billing_account=00CF06-C4A4BE-92FDD8
export TF_ADMIN=krispies-tf-admin
export TF_CREDS=~/.config/gcloud/terraform-admin.json
