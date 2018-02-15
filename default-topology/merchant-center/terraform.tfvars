
container_name           = "merchant-center"

container_mem_soft_limit = 256

container_port           = 80

task_desired_count       = {
  dev  = 1
  test = 1
  prod = 1
}

github_repository        = "mc-accelerator"
