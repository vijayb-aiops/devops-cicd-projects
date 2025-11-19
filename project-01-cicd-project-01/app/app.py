
---

### 🐳 `app/app.py` Content (Simple Flask App)

This is the web application that will be deployed:

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Hello from GitHub Actions + ECS!</h1><p>Deployment is automated.</p>"

@app.route('/health')
def health():
    return {"status": "ok"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)