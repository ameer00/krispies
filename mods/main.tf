// main file

module "provider" {
  source  = "./provider"
  }
  
module "host_project" {
  source  = "./host-project"
  }
  
module "vpc" {
  source  = "./vpc"
  }
  
module "subnets" {
  source  = "./subnets"
  }
