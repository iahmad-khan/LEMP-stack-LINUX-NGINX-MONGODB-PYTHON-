import os
from flask import Flask, redirect, url_for, request, render_template
from pymongo import MongoClient
import socket

app = Flask(__name__)

client = MongoClient('192.168.50.12',27017)
db = client.testdb


@app.route('/')
def test():

    _items = db.testdb.find()
    items = [item for item in _items]

    return render_template('index.html', items=items)


@app.route('/new', methods=['POST'])
def new():

    item_doc = {
        #'name': request.form['name'],
        'name': "Server Your are hitting",
        #'description': request.form['description']
        'description': socket.getfqdn()
    }
    db.testdb.insert_one(item_doc)

    return redirect(url_for('test'))

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
