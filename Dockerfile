FROM node:11.13

ENV ELECTRON_SYMBOL_VERSION=5.0.8

RUN mkdir /symbols && mkdir -p /app/pool/symbols

WORKDIR /symbols

RUN curl -L -o darwin.x64.zip https://github.com/electron/electron/releases/download/v${ELECTRON_SYMBOL_VERSION}/electron-v${ELECTRON_SYMBOL_VERSION}-darwin-x64-symbols.zip && unzip darwin.x64.zip && mv breakpad_symbols/* /app/pool/symbols && rm -rf ./*

RUN curl -L -o win32.zip https://github.com/electron/electron/releases/download/v${ELECTRON_SYMBOL_VERSION}/electron-v${ELECTRON_SYMBOL_VERSION}-win32-ia32-symbols.zip && unzip win32.zip && mv breakpad_symbols/* /app/pool/symbols && rm -rf ./*

RUN npm install -g grunt

ADD src /app/src
ADD package.json /app
ADD views /app/views
ADD Gruntfile.coffee /app

WORKDIR /app

RUN npm install .

RUN grunt

CMD node lib/app.js
