# frozen_string_literal: true

class EncryptAPIKey < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Encryption.config.support_unencrypted_data = true

    User.find_each(&:encrypt)

    ActiveRecord::Encryption.config.support_unencrypted_data = false

    change_column_null :users, :api_key, false
    add_index :users, :api_key, unique: true
  end
end
