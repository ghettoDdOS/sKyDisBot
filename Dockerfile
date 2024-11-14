# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.18.0

FROM node:${NODE_VERSION} AS base

ENV DEBIAN_FRONTEND=noninteractive \
    CONFIG_PATH=/config.json

WORKDIR /usr/src/app

FROM base AS deps

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qy; \
    apt install -qy --no-install-recommends \
    build-essential \
    libtool \
    autoconf \
    automake \
    tcc; \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=cache,target=/root/.yarn \
    yarn install --production --frozen-lockfile

FROM deps AS build

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=cache,target=/root/.yarn \
    yarn install --frozen-lockfile

COPY . .
RUN yarn run build

FROM base AS final

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qy; \
    apt install -qy --no-install-recommends \
    ffmpeg; \
    rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

USER node

COPY package.json .

COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/build ./build

CMD ["yarn", "start"]
