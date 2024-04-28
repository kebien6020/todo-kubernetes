# syntax=docker/dockerfile:1
FROM node:20-alpine

RUN apk add --no-cache dumb-init

WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install --omit=dev --no-save
COPY src src

EXPOSE 4300
CMD ["dumb-init", "node", "src/index.mjs"]
