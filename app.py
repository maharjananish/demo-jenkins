from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "<h1>Helo Hello Hello from Anish + EKS!</h1><p>Modified Pipeline is working fine again aggain.</p>"

@app.route('/health')
def health():
    return {"status": "ok"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
