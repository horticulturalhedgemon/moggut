from flask import Flask, render_template, request, jsonify,Response
import json;
import os;
app = Flask(__name__)

with open("files/entry_list.txt", "r") as file:
    entryList = json.loads(file.read())
    print(entryList)
    print(type(entryList))
entryId = len(entryList)

def generatePrompt():
    return "random prompt";

#add a new entry to entryList, create a new file 
@app.route("/api/newEntry", methods = ['POST'])
def addNewEntry():
    if (request.method == 'POST'):
        global entryList, entryId
        #create file, generate a random prompt, increment daycount/id, and add to entrylist
        #return prompt, daycount, file contents
        newEntry = ['day '+str(entryId),generatePrompt(),str(entryId)]
        print(type(entryList))
        entryList.insert(len(entryList)-1,newEntry)
        with open("files/entry_list.txt", "w") as file:
            file.write(json.dumps(entryList))
        with open("files/file"+str(entryId)+".txt", "x") as file:
            file.write(json.dumps([{"insert":"\n"}]));
            entryId += 1
            return newEntry;

@app.route("/api/entry/<int:id>", methods = ['GET','PUT'])
def manageEntry(id):
    if (request.method == 'GET'):
        #get string output, turn to json, return
        with open("files/file"+str(id)+".txt", "r") as file:
            return file.read();
    if (request.method == 'PUT'):
        #if file exists, update file
        if os.path.exists("files/file"+str(id)+".txt"):
            with open("files/file"+str(id)+".txt", "w") as file:
                file.write(json.dumps(request.json));
                return jsonify(id);
        else:
            return "file does not exist", 404
    


@app.route("/api/entry_list", methods = ['GET'])
def getEntryList():
    global entryList
    if (request.method == 'GET'):
        print(type(entryList))
        return entryList
    

if __name__ == "__main__":
    app.run(debug=True)