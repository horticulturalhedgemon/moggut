from flask import Flask, render_template
app = Flask(__name__)
@app.route("/", methods = ['GET'])
def generatePrompt():
    return "random prompt";

if __name__ == "__main__":
    app.run(debug=True)