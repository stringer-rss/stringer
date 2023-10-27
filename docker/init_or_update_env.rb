required_env = {
  "SECRET_KEY_BASE" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_PRIMARY_KEY" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_DETERMINISTIC_KEY" => `openssl rand -hex 64`.strip,
  "ENCRYPTION_KEY_DERIVATION_SALT" => `openssl rand -hex 64`.strip,
  # ternary operators ensure that we can set the database url if it does not exist
  "POSTGRES_USER" => ENV["POSTGRES_USER"] ? ENV["POSTGRES_USER"] : "stringer",
  "POSTGRES_PASSWORD" => ENV["POSTGRES_PASSWORD"] ? ENV["POSTGRES_PASSWORD"] : `openssl rand -hex 32`.strip,
  "POSTGRES_HOSTNAME" => ENV["POSTGRES_HOSTNAME"] ? ENV["POSTGRES_HOSTNAME"] : "stringer-postgres",
  "POSTGRES_DB" => ENV["POSTGRES_DB"] ? ENV["POSTGRES_DB"] : "stringer",
  "FETCH_FEEDS_CRON" => "*/5 * * * *",
  "CLEANUP_CRON" => "0 0 * * *",
}

required_env["DATABASE_URL"] = "postgres://#{required_env['POSTGRES_USER']}:#{required_env['POSTGRES_PASSWORD']}@#{required_env['POSTGRES_HOSTNAME']}/#{required_env['POSTGRES_DB']}"

required_env.each do |key, value|
  next if ENV[key].present?

  File.open("/.env", "a") { |file| file << "#{key}=#{value}\n"
end
