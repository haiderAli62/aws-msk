import os
import boto3
import json
import datetime

S3_RESOURCE = boto3.resource('s3')

def lambda_handler(event, context):
    print('-----------------')
    print(event)
    content_type = ""
    json_string = json.dumps(event['records'])
    ct = datetime.datetime.now()
    dt_epoch = str(convert_datetime_to_epoch(ct))
    file_name = str(ct.date())+ '-' +dt_epoch+ ".json"
    print(file_name)
    tmpfile = "/tmp/{}".format(file_name)
    with open(tmpfile, 'w') as outfile:
        outfile.write(json_string)


    upload_to_s3(tmpfile, file_name, content_type)


    return {
        'statusCode': 200,
        'body': json.dumps('Process completed!')
    }

def upload_to_s3(report_file, s3_key, content_type):
    s3 = boto3.client("s3")
    bucket = os.environ['S3_MSK_DATA_BUCKET_NAME']
    with open(report_file, "rb") as f:
        s3.upload_fileobj(
            open(report_file, "rb"),
            bucket,
            s3_key,
            ExtraArgs={"ContentType": content_type},
        )

def convert_datetime_to_epoch(dateTime):
    epoch = datetime.datetime.utcfromtimestamp(0)
    return int((dateTime - epoch).total_seconds() * 1000.0)


#bin/kafka-topics.sh --create --zookeeper z-1.demo-cluster-1.dpjps1.c7.kafka.us-east-2.amazonaws.com:2181,z-3.demo-cluster-1.dpjps1.c7.kafka.us-east-2.amazonaws.com:2181,z-2.demo-cluster-1.dpjps1.c7.kafka.us-east-2.amazonaws.com:2181 --replication-factor 3 --partitions 1 --topic msk-test-topic
#./kafka-console-producer.sh --broker-list b-3.demo-cluster-1.dpjps1.c7.kafka.us-east-2.amazonaws.com:9092 --producer.config client.properties --topic msk-test-topic


#./kafka-console-consumer.sh --bootstrap-server b-3.demo-cluster-1.dpjps1.c7.kafka.us-east-2.amazonaws.com:9092 --consumer.config client.properties --topic msk-test-topic --from-beginning