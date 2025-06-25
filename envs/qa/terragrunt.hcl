include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/vpc"
}

inputs = {
  cidr_block = "10.1.0.0/16"
  name       = "qa-vpc"
  region     = getenv("TF_VAR_REGION")  # <-- Pass region from env var
}
