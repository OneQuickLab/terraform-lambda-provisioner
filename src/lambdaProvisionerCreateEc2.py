import boto3
import json
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):

    bucket = "demo-lambda-provisioner"
    key = "templates.json"

    try:

        # fetch templates
        data = s3.get_object(Bucket=bucket,Key=key)

        json_data = data["Body"].read().decode()
        data = json.loads(json_data)

        # parse query params
        instanceTemplate = event['queryStringParameters']['instanceTemplate']

        ec2 = boto3.client('ec2', region_name=data["provisioner"][instanceTemplate]["region"])

        instance = ec2.run_instances(
            ImageId=data["provisioner"][instanceTemplate]["ami"],
            InstanceType=data["provisioner"][instanceTemplate]["instance_type"],
            KeyName=data["provisioner"][instanceTemplate]["key_name"],
            MaxCount=int(data["provisioner"][instanceTemplate]["instance_count"]),
            MinCount=int(data["provisioner"][instanceTemplate]["instance_count"])
        )

        print ("@@@ new " + instanceTemplate + " instance created @@@")
        instance_id = instance['Instances'][0]['InstanceId']

        # ec2.create_tags(Resources=[instance_id], Tags=[
        #     {
        #         'Key': 'Name',
        #         'Value': "demo-" + instanceTemplate,
        #     },
        # ])

        provisionerResponse = {}
        provisionerResponse['instanceId'] = instance_id

        responseObject = {}
        responseObject['statusCode'] = 200
        responseObject['headers'] = {}
        responseObject['headers']["Content-Type"] = "application/json"
        responseObject['body'] = json.dumps(provisionerResponse)

        return responseObject

    except Exception as e:
        print(e)
        raise e