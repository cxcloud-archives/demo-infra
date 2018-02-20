application_name    = "cxcloud"

dynatrace_enabled   = true

svc_domain_names     = {
  dev  = "dev.cxcloud.com"
  test = "test.cxcloud.com"
  prod = "demo.cxcloud.com"
}

mc_domain_names      = {
  dev  = "mc.dev.cxcloud.com"
  test = "mc.test.cxcloud.com"
  prod = "mc.cxcloud.com"
}

zone_domain_name = "cxcloud.com."

vpc_cidr            = {
  dev  = "10.0.0.0/20"
  test = "10.0.16.0/20"
  prod = "10.0.32.0/20"
}

vpc_public_subnets  = {
  dev  = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  test = ["10.0.16.0/23", "10.0.18.0/23", "10.0.20.0/23"]
  prod = ["10.0.32.0/23", "10.0.34.0/23", "10.0.36.0/23"]
}

vpc_private_subnets = {
  dev  = ["10.0.6.0/23", "10.0.8.0/23", "10.0.10.0/23"]
  test = ["10.0.22.0/23", "10.0.24.0/23", "10.0.26.0/23"]
  prod = ["10.0.38.0/23", "10.0.40.0/23", "10.0.42.0/23"]
}