FROM node:alpine
RUN npm i -g @slidev/cli
RUN apk add git wget
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
RUN tar -xf ngrok-v3-stable-linux-arm64.tgz -C /usr/local/bin/
RUN ngrok config add-authtoken 2NHKN6D44i78wv5n592Yvs39zop_7xwbTYZmjuX9dgT6QJKvV
# RUN slidev --remote=ad.5319.93A
# CMD [ "ngrok", "http", "3030" ]