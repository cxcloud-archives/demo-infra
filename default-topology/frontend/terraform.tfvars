
container_name           = "frontend"

container_mem_soft_limit = 256

container_port           = 80

task_desired_count       = {
  dev  = 1
  test = 1
  prod = 1
}

github_repository        = "frontend-accelerator"
