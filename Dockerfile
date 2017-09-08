FROM ruby:2.3.3

ENV RACK_ENV=production
ENV PORT=8080

EXPOSE 8080

WORKDIR /app
ADD Gemfile Gemfile.lock /app/
RUN bundle install --deployment

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      supervisor locales nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=96960ba3207756bb01e6892c978264e5362e117e

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

ADD docker/supervisord.conf /etc/supervisord.conf
ADD docker/start.sh /app/
ADD . /app

RUN useradd -m stringer
RUN chown -R stringer:stringer /app
USER stringer

CMD /app/start.sh
