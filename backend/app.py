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
DYNAMODB_TABLE_NAME = "demo-app-file-metadata-dynamodb"

# AWS S3 Client
s3_client = boto3.client("s3")

# Create Database if Not Exists
def initialize_database():
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD)
    with conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {RDS_DATABASE}")
    conn.commit()
    conn.close()

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

if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000, debug=True)