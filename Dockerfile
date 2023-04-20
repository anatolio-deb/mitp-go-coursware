FROM node:alpine
RUN npm i -g @slidev/cli
RUN apk add git