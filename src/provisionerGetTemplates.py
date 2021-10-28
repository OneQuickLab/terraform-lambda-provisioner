import boto3
import json
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):

    bucket = "btr-provisioner"
    key = "sample_templates.json"

    try:

        data = s3.get_object(Bucket=bucket,Key=key)

        json_data = data["Body"].read().decode()
        data = json.loads(json_data)

        return {
            "response_code" : 200,
            "headers: " : {
                "Content-Type":"application/json"
            },
            "data" : data
        }

    except Exception as e:
        print(e)
        raise e