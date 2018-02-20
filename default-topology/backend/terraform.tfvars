
container_name           = "backend"

container_mem_soft_limit = 256

container_port           = 4003

task_desired_count       = {
  dev  = 1
  test = 1
  prod = 1
}

github_repository        = "api-accelerator"

