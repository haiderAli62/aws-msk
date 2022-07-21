resource "aws_s3_bucket" "s3_msk_data_bucket" {
  bucket = "${var.ENV}-msk-data-bucket"

}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3_msk_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
