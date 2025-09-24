# frozen_string_literal: true

class EncryptAPIKey < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Encryption.config.support_unencrypted_data = true

    encrypt_api_keys

    ActiveRecord::Encryption.config.support_unencrypted_data = false

    change_column_null :users, :api_key, false
    add_index :users, :api_key, unique: true
  end

  private

  def encrypt_api_keys
    connection.select_all("SELECT id, api_key FROM users").each do |user|
      encrypted_api_key = ActiveRecord::Encryption.encryptor.encrypt(user["api_key"])
      connection.update("UPDATE users SET api_key = #{connection.quote(encrypted_api_key)} WHERE id = #{user['id']}")
    end
  end
end
