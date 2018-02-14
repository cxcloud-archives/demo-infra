
container_name           = "backend"

container_mem_soft_limit = 256

container_port           = 4003

task_desired_count       = {
  dev  = 1
  test = 2
  prod = 2
}

github_repository        = "api-accelerator"

