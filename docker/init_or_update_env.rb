# frozen_string_literal: true

# Adds any missing secret keys to the .env file mounted into the container, so
# that a fresh docker compose install works without generating them by hand.
# Dotenv loads the file when Rails boots.

require "securerandom"

ENV_PATH = "/app/.env"
KEYS = [
  "SECRET_KEY_BASE",
  "ENCRYPTION_PRIMARY_KEY",
  "ENCRYPTION_DETERMINISTIC_KEY",
  "ENCRYPTION_KEY_DERIVATION_SALT"
].freeze

existing = File.read(ENV_PATH)
missing = KEYS.reject { |key| ENV.key?(key) || existing.match?(/^#{key}=/) }

File.open(ENV_PATH, "a") do |file|
  file << "\n" unless existing.empty? || existing.end_with?("\n")
  missing.each { |key| file << "#{key}=#{SecureRandom.hex(64)}\n" }
end
