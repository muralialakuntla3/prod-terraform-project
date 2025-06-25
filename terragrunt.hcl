remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terragrunt-backend-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-1"
  }
}
