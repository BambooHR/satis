FROM php:8.5.13-cli-alpine AS build

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

WORKDIR /satis

COPY . /satis/

RUN set -eux ; \
  apk add --no-cache git unzip ; \
  install-php-extensions zip ; \
  composer install \
    --no-interaction \
    --no-ansi \
    --no-scripts \
    --no-plugins \
    --no-dev \
    --prefer-dist \
    --no-progress \
    --no-suggest \
    --classmap-authoritative

FROM php:8.5.13-cli-alpine

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux ; \
  apk upgrade --no-cache ; \
  apk add --no-cache --upgrade \
    bash \
    curl \
    git \
    mercurial \
    openssh \
    openssl \
    p7zip \
    subversion \
    unzip \
    zip ; \
  install-php-extensions \
    bz2 \
    sockets \
    zip

ENV COMPOSER_HOME /composer

COPY php-cli.ini /usr/local/etc/php/
COPY --from=build /satis /satis/

WORKDIR /build

ENTRYPOINT ["/satis/bin/docker-entrypoint.sh"]

CMD ["--ansi", "-vvv", "build", "/build/satis.json", "/build/output"]
