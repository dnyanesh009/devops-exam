import json
import boto3
import requests
import base64
import os

# # Set environment variables for VPC and subnet
PRIVATE_SUBNET_ID = os.environ['PRIVATE_SUBNET_ID']  # Lambda will get subnet ID from environment variables
# FULL_NAME = os.environ['FULL_NAME']  # Lambda will get your full name from environment variables
# EMAIL = os.environ['EMAIL']  # Lambda will get your email from environment variables

# The endpoint URL and the headers for the request
ENDPOINT_URL = "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data"
HEADERS = {
    'X-Siemens-Auth': 'test',  # Security header for the request
    'Content-Type': 'application/json'
}

# Lambda function handler
def lambda_handler(event, context):
    # Create the payload with the provided data
    payload = {
        "subnet_id": PRIVATE_SUBNET_ID,  # Use the Private Subnet ID dynamically from environment variables
        "name": "Ankita Ghogare",  # Use your full name dynamically from environment variables
        "email": "ankitak7721@gmail.com"  # Use your email dynamically from environment variables
    }

    # Post request to the remote API endpoint
    try:
        response = requests.post(ENDPOINT_URL, headers=HEADERS, json=payload)
        
        # If the response status code is 200, decode the LogResult from base64
        if response.status_code == 200:
            print("Request successful, processing response...")
            
            # LogResult is base64 encoded, so we need to decode it
            log_result_base64 = response.json().get("LogResult")
            if log_result_base64:
                decoded_log_result = base64.b64decode(log_result_base64).decode('utf-8')
                print(f"Decoded LogResult: {decoded_log_result}")
            
            # Return a successful response
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Request successful',
                    'logResult': decoded_log_result
                })
            }
        else:
            # Return error response if the status code is not 200
            return {
                'statusCode': response.status_code,
                'body': json.dumps({
                    'message': 'Request failed',
                    'error': response.text
                })
            }
    
    except Exception as e:
        # Log any exceptions and return error response
        print(f"An error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Internal server error',
                'error': str(e)
            })
        }
