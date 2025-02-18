from flask import Flask, render_template, request, jsonify
import json;
app = Flask(__name__)
@app.route("/api/prompt", methods = ['GET'])
def generatePrompt():
    return "random prompt";

#sql conversion:
#

@app.route("/api/entry/<int:id>", methods = ['GET','PUT','DELETE'])
def manageEntry(id):
    if (request.method == 'GET'):
        ##get string output, turn to json, return
        faihul = open("files/file"+str(id)+".txt", "r");
        return faihul.read();
    if (request.method == 'PUT'):
        #if file exists, update file. if file doesn't exist, create file
        faihul = open("files/file"+str(id)+".txt", "w");
        faihul.write(json.dumps(request.json));
        return jsonify(id);
        


if __name__ == "__main__":
    app.run(debug=True)