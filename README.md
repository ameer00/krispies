# krispies VPC scale test

Use mods in the mods folder

Current state at 10 svc projects using 06291 prefix and 82 subnets

82 is max subnets with 100 Subnetwork limit due to 500 total global subnet limit and with 5 secondary ranges each, 82 is max

Note: Currently have to run terraform apply twice, it fails the first time since the subnets are not created prior to share_subnet module.  However, the second time the share_subnet module succeeds.

Please read the instructions in the main.tf file
