FROM node:16

RUN apt-get update && apt-get install -y dumb-init

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --production
COPY src src

EXPOSE 4300
CMD ["dumb-init", "node", "src/index.mjs"]
