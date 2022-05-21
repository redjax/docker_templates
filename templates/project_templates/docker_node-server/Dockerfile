FROM node:16-alpine as base
# FROM node:16-bullseye as base
# FROM node:16 as base

# Set working directory in the container
WORKDIR /src
# COPY package.json and package-lock.json into container
COPY src/package*.json /
# Expose container app runs on
# EXPOSE 8080

## Production stage
FROM base as production
ENV NODE_ENV=production
RUN npm ci
# COPY ./src /src
COPY ./src /
CMD ["npm", "start"]

## Dev stage
FROM base as dev
ENV NODE_ENV=development
RUN npm i -g nodemon && npm i
COPY ./src /
CMD ["nodemon", "app.js"]
