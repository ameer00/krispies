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
  count	  = "82"
  project = "${module.vpc.project}"
  }

module "svc_projects" {
  count	  = "10"
  source  = "./svc-project"
  host_project  = "${module.subnets.project}"
  }

module "iam" {
  source  = "./iam"
  count	  = "${module.svc_projects.count}"
  host_project = "${module.svc_projects.host_project}"
  svc_project_number  = ["${module.svc_projects.svc_project_number}"]
}

module "share_subnet_project_1" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,0)}"

}

module "share_subnet_project_2" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,1)}"

}


module "share_subnet_project_3" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,2)}"

}


module "share_subnet_project_4" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,3)}"

}


module "share_subnet_project_5" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,4)}"

}


module "share_subnet_project_6" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,5)}"

}


module "share_subnet_project_7" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,6)}"

}


module "share_subnet_project_8" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,7)}"

}


module "share_subnet_project_9" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,8)}"

}


module "share_subnet_project_10" {
  source  = "./share-subnet"
  subnet_count   = "${module.subnets.count}"
  project = "${module.iam.host_project}"
  project_number = "${element(module.svc_projects.svc_project_number,9)}"

}

/*
module "gke_svc_project_1" {
  source = "./gke"
  svc_count = 0
  vpc     = "${module.vpc.vpc_link}"
  project = ["${module.svc_projects.svc_project}"]
  subnet  = ["${module.subnets.subnets_name}"]
}
*/


output "subnet_count" {
  value = "${module.subnets.count}"
}

output "subnets" {
  value = ["${module.subnets.subnets_name}"]
}
  
output "subnets_name" {
  value = ["${module.subnets.subnets_short_name}"]
}

output "count" {
  value	= "${module.iam.count}"
}

output "svc_project" {
  value = ["${module.svc_projects.svc_project}"]
}

output "svc_project_number" {
  value = ["${module.svc_projects.svc_project_number}"]
}

output "vpc_self_link" {
  value = "${module.vpc.vpc_link}"
}