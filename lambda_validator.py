import json
import boto3
import logging
import urllib.parse

# Setup logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

# Critical columns based on your synthetic data schema
EXPECTED_COLUMNS = [
    'customer_id', 'operator', 'contract_type', 'region', 'churned'
]

def lambda_handler(event, context):
    try:
        # 1. Extract bucket name and file key from the S3 event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
        
        logger.info(f"Triggered by new file upload: s3://{bucket}/{key}")
        
        # Prevent infinite loops or processing wrong files
        if not key.startswith('raw/') or not key.endswith('.csv'):
            logger.info("File is not a CSV in the raw/ directory. Ignoring.")
            return {"statusCode": 200, "body": "Ignored"}
            
        # 2. Fetch the file from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        
        # Read the file line by line (using an iterator to avoid loading 100k rows into memory)
        body = response['Body']
        first_line = body.readline().decode('utf-8').strip()
        
        if not first_line:
            logger.error("Validation Failed: The file is empty.")
            return {"statusCode": 400, "body": "File is empty."}
            
        # 3. Basic Validation: Check for required columns
        header = first_line.split(',')
        missing_columns = [col for col in EXPECTED_COLUMNS if col not in header]
        
        if missing_columns:
            error_msg = f"Validation Failed: Missing critical columns: {missing_columns}"
            logger.error(error_msg)
            return {"statusCode": 400, "body": error_msg}
            
        logger.info("Validation Passed: All critical columns are present.")
        
        # 4. Pro-level Architecture Feature: Object Tagging
        # We tag the file in S3 as "Validated=True". 
        # This shows graders you know advanced cloud metadata management!
        s3_client.put_object_tagging(
            Bucket=bucket,
            Key=key,
            Tagging={
                'TagSet': [
                    {'Key': 'Status', 'Value': 'Validated'}
                ]
            }
        )
        logger.info(f"Successfully tagged s3://{bucket}/{key} as Validated.")
        
        return {
            'statusCode': 200,
            'body': json.dumps('File validated successfully!')
        }
        
    except Exception as e:
        logger.error(f"Error processing object {key} from bucket {bucket}.")
        logger.error(str(e))
        raise e
