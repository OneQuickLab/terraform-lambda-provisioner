import boto3
import json
import urllib.parse
import uuid

s3 = boto3.client('s3')

def lambda_handler(event, context):

    bucket = "onequicklab-lambda-provisioner"
    key = "templates.json"

    try:

        # fetch templates
        data = s3.get_object(Bucket=bucket,Key=key)

        json_data = data["Body"].read().decode()
        data = json.loads(json_data)

        # parse query params
        instanceTemplate = event['queryStringParameters']['instanceTemplate']

        ec2 = boto3.resource('ec2', region_name=data["provisioner"][instanceTemplate]["region"])

        random_id = str(uuid.uuid4().fields[-1])[:5]

        instances = ec2.create_instances(
            ImageId=data["provisioner"][instanceTemplate]["ami"],
            InstanceType=data["provisioner"][instanceTemplate]["instance_type"],
            KeyName=data["provisioner"][instanceTemplate]["key_name"],
            MaxCount=int(data["provisioner"][instanceTemplate]["instance_count"]),
            MinCount=int(data["provisioner"][instanceTemplate]["instance_count"]),
            TagSpecifications=[
                {
                  'ResourceType': 'instance',
                  'Tags': [
                    {
                      'Key': 'Name',
                      'Value': "onequicklab-" + instanceTemplate + "-" + random_id
                    }
                  ]
                },
            ]
        )

        print ("@@@ new " + instanceTemplate + " instance created @@@")

        provisionerResponse = {}

        for instance in instances:
            print(f'EC2 instance "{instance.id}" has been launched.')

            provisionerResponse['instance_name'] = "onequicklab-" + instanceTemplate + "-" + random_id
            provisionerResponse['instance_id'] = instance.id

        responseObject = {}
        responseObject['statusCode'] = 200
        responseObject['headers'] = {}
        responseObject['headers']["Content-Type"] = "application/json"
        responseObject['body'] = json.dumps(provisionerResponse)

        return responseObject

    except Exception as e:
        print(e)
        raise e