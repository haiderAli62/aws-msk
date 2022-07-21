resource "aws_vpc" "msk_vpc" {
  cidr_block = "192.168.0.0/22"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = "192.168.0.0/24"
  vpc_id            = aws_vpc.msk_vpc.id
}

resource "aws_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block        = "192.168.1.0/24"
  vpc_id            = aws_vpc.msk_vpc.id
}

resource "aws_subnet" "subnet_az3" {
  availability_zone = data.aws_availability_zones.azs.names[2]
  cidr_block        = "192.168.2.0/24"
  vpc_id            = aws_vpc.msk_vpc.id
}

resource "aws_security_group" "msk_sg" {
  vpc_id = aws_vpc.msk_vpc.id
}



resource "aws_msk_cluster" "test_msk_cluster" {
  cluster_name           = "${var.ENV}-msk-cluster"
  kafka_version          = "2.6.2"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    ebs_volume_size = 1
    client_subnets = [
      aws_subnet.subnet_az1.id,
      aws_subnet.subnet_az2.id,
      aws_subnet.subnet_az3.id,
    ]
    security_groups = [aws_security_group.msk_sg.id]
  }

  # client_authentication {
  #   sasl {
  #     iam = true
  #     scram = true 
  #   }
  # }

  encryption_info {

    encryption_in_transit {
       client_broker =  "TLS_PLAINTEXT" #"PLAINTEXT" #
       in_cluster  = true
    }
  }

}

#############################
resource "aws_lambda_event_source_mapping" "msk_cluster_lambda_event_source_mapping" {
  event_source_arn  = "${aws_msk_cluster.test_msk_cluster.arn}"
  enabled           = true
  topics            = ["test-topic"]
  function_name     = "${aws_lambda_function.lambda_msk_consumer_function.arn}"
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "lambda_permission" {
  function_name = "${aws_lambda_function.lambda_msk_consumer_function.function_name}"
  statement_id  = "msk-lambda-permission"
  action        = "lambda:InvokeFunction"
  principal     = "kafka.amazonaws.com"
  source_arn = "${aws_msk_cluster.test_msk_cluster.arn}"
}


#bin/kafka-topics.sh --create --zookeeper z-1.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:2181,z-3.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:2181,z-2.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:2181 --replication-factor 3 --partitions 1 --topic test-topic


## producer or consumer 

#./kafka-console-producer.sh --broker-list b-3.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092,b-1.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092,b-2.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092 --producer.config client.properties --topic test-topic


#./kafka-console-consumer.sh --bootstrap-server b-3.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092,b-2.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092,b-1.haider-test-msk-cluste.e4fyou.c7.kafka.us-east-2.amazonaws.com:9092 --consumer.config client.properties --topic test-topic --from-beginning