#!/usr/bin/env sh
if [ -d /app/.env ]; then
  cat <<-EOF
	Error: /app/.env is a directory, not a file. Docker creates one when the
	file to mount is missing. Remove it, run \`touch .env\` next to
	docker-compose.yml and start again.
	EOF

  exit 1
fi

if [ -f /app/.env ]; then
  ruby /app/docker/init_or_update_env.rb || exit 1
fi

if [ -z "$DATABASE_URL" ]; then
  cat <<-EOF
	Error: no DATABASE_URL was specified.
	EOF

  exit 1
fi

rails assets:precompile

: ${FETCH_FEEDS_CRON:='*/5 * * * *'}
: ${CLEANUP_CRON:='0 0 * * *'}

cat <<-EOF > /app/crontab
	$FETCH_FEEDS_CRON cd /app && bundle exec rake fetch_feeds
	$CLEANUP_CRON cd /app && bundle exec rake cleanup_old_stories
EOF

exec /usr/bin/supervisord -c /etc/supervisord.conf
