
"""
🐳 `app/app.py` Content (Simple Flask App)
This is the web application that will be deployed:
"""
# Simple Flask app for ECS deployment
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    # Return a basic HTML greeting
    return "<h1>Hello from GitHub Actions + ECS!</h1><p>Deployment is automated.</p>"

@app.route('/health')
def health():
    # Health-check endpoint for ECS/ALB
    return {"status": "ok"}, 200

if __name__ == '__main__':
    # Run the Flask app on all interfaces
    app.run(host='0.0.0.0', port=5000)
