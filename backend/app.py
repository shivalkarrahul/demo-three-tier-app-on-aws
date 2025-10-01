from flask import Flask, request, jsonify
import pymysql
import boto3
from flask_cors import CORS
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # ✅ Allow all origins
# RDS and S3 Configurations
RDS_HOST = "CHANGE_ME"
RDS_USER = "CHANGE_ME"
RDS_PASSWORD = "CHANGE_ME"
RDS_DATABASE = "demo"
S3_BUCKET = "CHANGE_ME"
DYNAMODB_TABLE_NAME = “demo-app-file-metadata-dynamodb"
# AWS S3 Client
s3_client = boto3.client("s3")
# Create Database if Not Exists
def initialize_database():
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD)
    with conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {RDS_DATABASE}")
    conn.commit()
    conn.close()
    # Now connect to the newly created database
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)
    with conn.cursor() as cursor:
        cursor.execute(
            """CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL
            )"""
        )
    conn.commit()
    conn.close()

# Connect to RDS
def get_db_connection():
    return pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)

# --------------------
# Health Check
# --------------------
@app.route("/", methods=["GET"])
def healthcheck():
    return jsonify({"status": "ok", "message": "Service is healthy"}), 200

# API to Insert User into RDS
@app.route("/insert", methods=["POST"])
def insert():
    data = request.json
    name = data["name"]
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO users (name) VALUES (%s)", (name,))
    conn.commit()
    conn.close()
    return jsonify({"message": "User inserted successfully!"})

# API to Fetch Users from RDS
@app.route("/fetch", methods=["GET"])
def fetch():
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
    conn.close()
    return jsonify({"users": users})

# API to Upload File to S3
@app.route("/upload", methods=["POST"])
def upload():
    file = request.files["file"]
    s3_client.upload_fileobj(file, S3_BUCKET, file.filename)
    return jsonify({"message": "File uploaded successfully!"})

# API to List Files from S3
@app.route("/list_files", methods=["GET"])
def list_files():
    objects = s3_client.list_objects_v2(Bucket=S3_BUCKET)
    files = [obj["Key"] for obj in objects.get("Contents", [])]
    return jsonify({"files": files})

# API to Get File Metadata from DynamoDB
@app.route("/get_file_metadata", methods=["GET"])
def get_file_metadata():
    dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
    table = dynamodb.Table(DYNAMODB_TABLE_NAME)
    response = table.scan()
    metadata = response.get("Items", [])
    return jsonify({"files_metadata": metadata})
if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000, debug=True)