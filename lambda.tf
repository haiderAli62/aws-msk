data "archive_file" "lambda_msk_consumer_archive" {
    type = "zip"
    source_file = "code/msk-consumer.py"
    output_path = "zip/msk-consumer.zip"
}

resource "aws_lambda_function" "lambda_msk_consumer_function" {
    filename = "zip/msk-consumer.zip"
    function_name = "${var.ENV}-msk-consumer-function"
    role = "${aws_iam_role.msk_consumer_lambda_role.arn}"
    handler = "msk-consumer.lambda_handler"
    source_code_hash = "${data.archive_file.lambda_msk_consumer_archive.output_base64sha256}"
    runtime = "python3.9"
    timeout = "900"

    environment {
        variables = {            
            "S3_MSK_DATA_BUCKET_NAME" = "${aws_s3_bucket.s3_msk_data_bucket.id}"
        }
    }
}
