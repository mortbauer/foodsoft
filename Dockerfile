FROM ruby:2.7.8 as builder

RUN supercronicUrl=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 && \
    supercronicBin=/usr/local/bin/supercronic && \
    supercronicSha1sum=96960ba3207756bb01e6892c978264e5362e117e && \
    curl -fsSL -o "$supercronicBin" "$supercronicUrl" && \
    echo "$supercronicSha1sum  $supercronicBin" | sha1sum -c - && \
    chmod +x "$supercronicBin"

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /usr/src/app

RUN --mount=type=cache,target=/var/cache/apt/ \
    buildDeps='libmagic-dev mariadb-server nodejs' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps 

COPY plugins plugins
COPY config config
COPY config.ru Gemfile Gemfile.lock proc-start Procfile Rakefile VERSION ./
COPY app app
COPY bin bin
COPY db db
COPY lib lib
COPY script script
COPY spec spec
COPY vendor vendor

# install dependencies and generate crontab
RUN --mount=type=cache,target=/usr/local/bundle/ \
    echo 'gem: --no-document' >> ~/.gemrc && \
    gem install bundler -v 2.4.22 && \
    bundle config build.nokogiri "--use-system-libraries" && \
    bundle config set --local without 'development test' && \
    bundle install -j 4 && \
    bundle exec whenever >crontab


FROM builder as compiler

# compile assets with temporary mysql server
RUN --mount=type=cache,target=/usr/local/bundle/ \
    export DATABASE_URL=mysql2://localhost/temp?encoding=utf8 && \
    export SECRET_KEY_BASE=thisisnotimportantnow && \
    /etc/init.d/mariadb start && \
    mariadb -e "CREATE DATABASE temp" && \
    cp config/app_config.yml.SAMPLE config/app_config.yml && \
    cp config/cable.yml.SAMPLE config/cable.yml && \
    cp config/database.yml.MySQL_SAMPLE config/database.yml && \
    cp config/storage.yml.SAMPLE config/storage.yml && \
    RAILS_ENV=production bundle exec rake db:setup assets:precompile && \
    /etc/init.d/mariadb stop && \
    cp -r /usr/local/bundle /bundle

FROM builder as app
COPY --from=compiler /bundle /usr/local/bundle
COPY --from=compiler /usr/src/app/public /usr/src/app/public
COPY --from=compiler /usr/src/app/config /usr/src/app/config

# Make relevant dirs and files writable for app user
RUN mkdir -p tmp storage && \
    chown nobody config/app_config.yml && \
    chown nobody tmp && \
    chown nobody storage

COPY docker-entrypoint.sh ./

# Run app as unprivileged user
USER nobody

EXPOSE 3000

VOLUME /usr/src/app/storage

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
