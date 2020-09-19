resource "aws_s3_bucket" "output" {
  bucket = "${var.scope}-output"
  acl = "private"
  force_destroy = true
  lifecycle_rule {
    id = "remove_after_1d"
    enabled = true
    expiration {
      days = 1
    }
  }
  tags = {
    scope = "${var.scope}"
  }
}
