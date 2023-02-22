FROM node:14

WORKDIR /app/

RUN apt -y update \
    && apt -y upgrade \
    && apt -y install \
    bash \
    ffmpeg

COPY . /app/

RUN npm install

RUN npm run build

ENTRYPOINT [ "npm", "run", "start" ]
