FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV VERSION="10.0.0"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk git

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

RUN apk add --no-cache git
COPY --from=build --chown=node:node /prod/api /app

RUN git init \
    && git config user.email "cobalt@local" \
    && git config user.name "cobalt" \
    && git remote add origin https://github.com/Kanezkozx/cobalt.git \
    && git commit --allow-empty -m "init"

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
