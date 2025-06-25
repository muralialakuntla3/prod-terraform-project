include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/vpc"
}

inputs = {
  name       = "dev-vpc"
  cidr_block = "10.0.0.0/16"
  region     = getenv("TF_VAR_REGION")  # <-- Pass region from env var
}