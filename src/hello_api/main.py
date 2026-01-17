from functions_framework import http
from google.cloud import firestore
from flask import jsonify
import os

FIRESTORE_DATABASE = os.getenv("FIRESTORE_DATABASE")

db = firestore.Client(database=FIRESTORE_DATABASE)


@http
def hello_world(request):
     # Set CORS headers for the preflight request
    if request.method == "OPTIONS":
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "3600",
        }

        return ("", 204, headers)
    
    headers = {"Access-Control-Allow-Origin": "*"}
    
    try:
        request_args = request.args if request.args else {}
        name = request_args.get('name', 'World')
        
        doc_ref = db.collection('greetings').document(name)
        doc = doc_ref.get()
        
        count = 1
        
        if doc.exists:
            data = doc.to_dict()
            
            if data and 'count' in data:
                count = data['count']
                count += 1
        
        doc_ref.set({'count': count})
        print(f"The function is called for {name} and {count} times")
        return (jsonify({
                "greeting": f"Hello! {name}!",
                "count": count
            }), 200, headers)

    except Exception as e:
        print(f"Error: {str(e)}")
        return (jsonify({
            "error": str(e)
        }), 500, headers)
    