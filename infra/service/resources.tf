data "aws_s3_bucket" "output" {
  bucket = "${var.scope}-output"
}