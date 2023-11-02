# frozen_string_literal: true

module Secrets
  def self.generate_secret(length)
    `openssl rand -hex #{length}`.strip
  end
end

pg_user = ENV.fetch("POSTGRES_USER", "stringer")
pg_password = ENV.fetch("POSTGRES_PASSWORD", Secrets.generate_secret(32))
pg_host = ENV.fetch("POSTGRES_HOSTNAME", "stringer-postgres")
pg_db = ENV.fetch("POSTGRES_DB", "stringer")

required_env = {
  "SECRET_KEY_BASE" => Secrets.generate_secret(64),
  "ENCRYPTION_PRIMARY_KEY" => Secrets.generate_secret(64),
  "ENCRYPTION_DETERMINISTIC_KEY" => Secrets.generate_secret(64),
  "ENCRYPTION_KEY_DERIVATION_SALT" => Secrets.generate_secret(64),
  "POSTGRES_USER" => pg_user,
  "POSTGRES_PASSWORD" => pg_password,
  "POSTGRES_HOSTNAME" => pg_host,
  "POSTGRES_DB" => pg_db,
  "FETCH_FEEDS_CRON" => "*/5 * * * *",
  "CLEANUP_CRON" => "0 0 * * *",
  "DATABASE_URL" => "postgres://#{pg_user}:#{pg_password}@#{pg_host}/#{pg_db}"
}

required_env.each do |key, value|
  next if ENV.key?(key)

  File.open("/app/.env", "a") { |file| file << "#{key}=#{value}\n" }
end
