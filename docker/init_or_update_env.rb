# frozen_string_literal: true

required_env = {
  "SECRET_KEY_BASE" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_PRIMARY_KEY" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_DETERMINISTIC_KEY" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_KEY_DERIVATION_SALT" => `openssl rand -hex 64`.strip,
  # ternary operators ensure that we can set the database url
  # if it does not exist
  "POSTGRES_USER" => if ENV.key?("POSTGRES_USER")
                       ENV["POSTGRES_USER"]
                     else
                       "stringer"
                     end,
  "POSTGRES_PASSWORD" => if ENV.key?("POSTGRES_PASSWORD")
                           ENV["POSTGRES_PASSWORD"]
                         else
                           `openssl rand -hex 32`.strip
                         end,
  "POSTGRES_HOSTNAME" => if ENV.key?("POSTGRES_HOSTNAME")
                           ENV["POSTGRES_HOSTNAME"]
                         else
                           "stringer-postgres"
                         end,
  "POSTGRES_DB" => if ENV.key?("POSTGRES_DB")
                     ENV["POSTGRES_DB"]
                   else
                     "stringer"
                   end,
  "FETCH_FEEDS_CRON" => "*/5 * * * *",
  "CLEANUP_CRON" => "0 0 * * *"
}

required_env["DATABASE_URL"] = "postgres://#{required_env['POSTGRES_USER']}:" \
                               "#{required_env['POSTGRES_PASSWORD']}@" \
                               "#{required_env['POSTGRES_HOSTNAME']}/" \
                               "#{required_env['POSTGRES_DB']}"

required_env.each do |key, value|
  next if ENV.key?(key)

  File.open("/app/.env", "a") { |file| file << "#{key}=#{value}\n" }
end
