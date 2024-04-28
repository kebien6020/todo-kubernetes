# syntax=docker/dockerfile:1
FROM node:20-alpine

RUN apk add --no-cache dumb-init

WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=./node_modules,sharing=locked \
    npm install --omit=dev --package-lock-only
COPY src src

EXPOSE 4300
CMD ["dumb-init", "node", "src/index.mjs"]
