# Builds the JS and CSS bundles. Only the output is copied into the final
# image, so it doesn't need Node or node_modules.
FROM node:26.13.1-slim AS assets

WORKDIR /app
RUN npm install --global pnpm@12.21.0
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml /app/
COPY patches /app/patches
RUN pnpm install --frozen-lockfile
COPY . /app
RUN pnpm build && pnpm build:css

FROM ruby:4.0.10

ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV PORT=8080
ENV BUNDLER_VERSION=2.6.2

EXPOSE 8080

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      supervisor locales vim nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL=C.UTF-8

ARG TARGETARCH
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-$TARGETARCH \
    SUPERCRONIC=supercronic-linux-$TARGETARCH \
    SUPERCRONIC_amd64_SHA1SUM=96960ba3207756bb01e6892c978264e5362e117e \
    SUPERCRONIC_arm_SHA1SUM=8c1e7af256ee35a9fcaf19c6a22aa59a8ccc03ef \
    SUPERCRONIC_arm64_SHA1SUM=f0e8049f3aa8e24ec43e76955a81b76e90c02270 \
    SUPERCRONIC_SHA1SUM="SUPERCRONIC_${TARGETARCH}_SHA1SUM"

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${!SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

WORKDIR /app
ADD Gemfile Gemfile.lock /app/
RUN gem install bundler:$BUNDLER_VERSION && bundle install

ADD docker/supervisord.conf /etc/supervisord.conf
ADD docker/start.sh /app/
ADD . /app
COPY --from=assets /app/app/assets/builds /app/app/assets/builds

# Rails needs these keys to boot, but precompiling doesn't use them. The JS
# and CSS were already built in the assets stage above.
RUN SECRET_KEY_BASE=dummy \
    ENCRYPTION_PRIMARY_KEY=dummy \
    ENCRYPTION_DETERMINISTIC_KEY=dummy \
    ENCRYPTION_KEY_DERIVATION_SALT=dummy \
    SKIP_CSS_BUILD=1 \
    SKIP_JS_BUILD=1 \
    bundle exec rails assets:precompile

RUN useradd -m stringer
RUN chown -R stringer:stringer /app
USER stringer

ENV RAILS_SERVE_STATIC_FILES=true

CMD /app/start.sh
