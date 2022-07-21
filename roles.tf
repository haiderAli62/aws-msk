resource "aws_iam_role" "msk_consumer_lambda_role" {
  name = "${var.ENV}-msk-consumer-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  
}


resource "aws_iam_policy" "msk_consumer_lambda_role_policy" {
  name = "${var.ENV}-msk-consumer-lambda-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": [
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:get*",
        "s3:list*",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:PutObjectAcl"        
      ],
      "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.s3_msk_data_bucket.id}/*"
      ]      
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka:DescribeCluster",
        "kafka:GetBootstrapBrokers",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVpcs",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"        
      ],
      "Resource": [
          "*"
      ]      
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_msk_consumer_role_attachment" {
  role       = "${aws_iam_role.msk_consumer_lambda_role.name}"
  policy_arn = "${aws_iam_policy.msk_consumer_lambda_role_policy.arn}"
}

#bin/kafka-topics.sh --create --zookeeper z-3.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:2181,z-1.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:2181,z-2.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:2181 --replication-factor 3 --partitions 1 --topic topic1

#./kafka-console-producer.sh --broker-list b-3.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092,b-2.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092,b-1.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092  --producer.config client.properties --topic topic1


#./kafka-console-consumer.sh --bootstrap-server b-3.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092,b-2.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092,b-1.demo-cluster-1.rlfu4k.c7.kafka.us-east-2.amazonaws.com:9092 --consumer.config client.properties --topic topic1 --from-beginning