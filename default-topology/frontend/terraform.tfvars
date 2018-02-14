
container_name           = "frontend"

container_mem_soft_limit = 256

container_port           = 80

task_desired_count       = {
  dev  = 1
  test = 2
  prod = 2
}

github_repository        = "frontend-accelerator"
