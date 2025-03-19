from flask import Flask, render_template, request, jsonify,Response
import json;
import random;
import os;
from datetime import datetime, date, timedelta
app = Flask(__name__)
if not os.path.exists("files/entry_list.txt"):
    with open("files/entry_list.txt", "w") as file:
        file.write(json.dumps([]));
with open("files/entry_list.txt", "r") as file:
    entryList = json.loads(file.read())
    print(entryList)
    print(type(entryList))
entryId = len(entryList)


#add a new entry to entryList, create a new file 
@app.route("/api/entry", methods = ['GET'])
def manageEntries():
    global entryList, entryId
    if (request.method == 'GET'):
        #compare date of last entry to today.
        #if before today, add new entries starting from that day while before today
        if len(entryList) > 0:
            lastDate = datetime.strptime(entryList[-1][0], "%B %d, %Y").date()
        else:
            lastDate = date.today() - timedelta(days=1)
        while lastDate < date.today():
            #create file, generate a random prompt, increment daycount/id, and add to entrylist
            #return prompt, daycount, file contents
            newDate = lastDate + timedelta(days=1)
            lastDate = newDate
            newEntry = [newDate.strftime("%B %d, %Y"),generatePrompt(),str(entryId)]
            entryList.append(newEntry)
            with open("files/entry_list.txt", "w") as file:
                file.write(json.dumps(entryList))
            with open("files/file"+str(entryId)+".txt", "x") as file:
                file.write(json.dumps([{"insert":"\n"}]));
                entryId += 1
        return entryList
        
        
        

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
    
def generatePrompt():
    #370100 words
    wordDict = None
    wordList = None
    with open("files/words_dictionary.json", "r") as file:
        wordDict = json.load(file)
        wordList = list(wordDict.keys())
        return ('%s %s %s' % (wordList[random.randint(0,370100)].capitalize(),wordList[random.randint(0,370100)].capitalize(),wordList[random.randint(0,370100)].capitalize()))

if __name__ == "__main__":
    app.run(debug=True)