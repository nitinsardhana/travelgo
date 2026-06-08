terraform {
  backend "s3" {
    bucket         = "travelgo-tf-state-nitinsardhana-001"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "travelgo-terraform-locks"
  }
}