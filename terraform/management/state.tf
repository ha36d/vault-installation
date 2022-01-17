terraform {
  backend "gcs" {
    bucket = "glass-oath-338523-vault-data"
    prefix = "identity-management"
  }
}

