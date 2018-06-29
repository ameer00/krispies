// main file

module "provider" {
  source  = "./provider"
  }
  
module "host_project" {
  source  = "./host-project"
  }
  
module "vpc" {
  source  = "./vpc"
  project = "${module.host_project.project_id}"
  }
  
module "subnets" {
  source  = "./subnets"
  project = "${module.vpc.project}"
  }
