from flask import Flask, jsonify, request
import boto3
from botocore.exceptions import NoCredentialsError

app = Flask(__name__)

# Initialize a session using Amazon S3
s3 = boto3.client('s3', region_name='us-west-2')

BUCKET_NAME = 'forhttpservice'

@app.route('/list-bucket-content/', defaults={'path': ''})
@app.route('/list-bucket-content/<path:path>')
def list_bucket_content(path):
    try:
        if path:
            path = path.rstrip('/') + '/'
        response = s3.list_objects_v2(Bucket=BUCKET_NAME, Prefix=path, Delimiter='/')

        contents = []
        if 'CommonPrefixes' in response:
            contents.extend([prefix['Prefix'] for prefix in response['CommonPrefixes']])
        if 'Contents' in response:
            contents.extend([content['Key'] for content in response['Contents'] if content['Key'] != path])

        return jsonify({"content": contents})
    except NoCredentialsError:
        return jsonify({"error": "Credentials not available"}), 403
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
