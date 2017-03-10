#!/bin/bash
apt-get update
apt-get install -y python python-pip python-virtualenv nginx gunicorn supervisor
pip install pymongo
pip install Flask-PyMongo
pip install pytz
pip install Flask==0.10.1
mkdir -p /home/www
cd /home/www
virtualenv env
sleep 1
source env/bin/activate
mkdir flask_project && cd flask_project
sleep 1
cat <<EOF > /home/www/flask_project/app.py
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
        'name': "Server Your are hitting",
        'description': socket.getfqdn()
    }
    db.testdb.insert_one(item_doc)

    return redirect(url_for('test'))

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
EOF
mkdir -p /home/www/flask_project/templates
sleep 1
cat <<EOF > /home/www/flask_project/templates/index.html
<form action="/new" method="POST">
  <input type="submit"></input>
</form>

{% for item in items %}
  <h1> {{ item.name }} </h1>
  <p> {{ item.description }} <p>
{% endfor %}
EOF
sleep 1
unlink /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/sites-available/*
touch /etc/nginx/sites-available/flask_project
sleep 1
cat <<EOF > /etc/nginx/sites-available/flask_project
server {
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /static {
        alias  /home/www/flask_project/templates/;
        index  index.html index.htm;
    }
}
EOF
ln -s /etc/nginx/sites-available/flask_project /etc/nginx/sites-enabled/flask_project
systemctl restart nginx
cat <<EOF > /etc/supervisor/conf.d/flask_project.conf
[program:flask_project]
command = gunicorn app:app -b localhost:8000
directory = /home/www/flask_project
user = nobody
EOF
sleep 1
supervisord -c /etc/supervisor/supervisord.conf 
supervisorctl  reload
supervisorctl  status
