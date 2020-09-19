resource "aws_s3_bucket" "output" {
  bucket = "${var.scope}-output"
  acl = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = {
    scope = "${var.scope}"
  }
}
