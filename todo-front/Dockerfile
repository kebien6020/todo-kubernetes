FROM node:16 as builder

ARG API_URL=/api

WORKDIR /build
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN API_URL=${API_URL} npm run build

FROM nginx:1.21.1

WORKDIR /app
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /build/dist dist
