terraform {
  backend "s3" {
    bucket = "terraform-bucket-1306"
    key = "ami/state"
    region = "us-east-1"
  }
}