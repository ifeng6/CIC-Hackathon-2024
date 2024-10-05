from flask import Flask, request

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def hello_world():
    return "<p>Hello, World!</p>"

