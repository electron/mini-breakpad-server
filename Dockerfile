FROM node:11.13

RUN npm install -g grunt

ADD . /app

WORKDIR /app

RUN npm install .

#CMD node lib/app.js

