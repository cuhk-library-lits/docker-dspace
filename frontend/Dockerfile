FROM node:16

ARG DSPACE_ANGULAR_RELEASE_URL=https://github.com/DSpace/dspace-angular/archive/refs/tags/dspace-7.5.tar.gz
ARG DSPACE_ANGULAR_FOLDER=dspace-angular-dspace-7.5

RUN cd / && \
    curl -sL ${DSPACE_ANGULAR_RELEASE_URL} | tar -xz && \
    rm -rf /usr/src/app && \
    mv ${DSPACE_ANGULAR_FOLDER} /usr/src/app && \
    chown -R node:node /usr/src/app

USER node
EXPOSE 4000
WORKDIR /usr/src/app

RUN yarn install && \
    yarn build:prod

CMD [ "node", "./dist/server/main.js" ]
