FROM node:18-alpine

WORKDIR /usr/src/app

COPY src/ ./src/
COPY package*.json ./

RUN npm install

EXPOSE 3000

CMD ["node", "src/index.js"]
