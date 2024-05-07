ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/node:22-bookworm as base 

WORKDIR /app

COPY ./frontend/package.json .
COPY ./frontend/package-lock.json .

RUN npm install

CMD ["npm", "run", "dev-in-docker"]
