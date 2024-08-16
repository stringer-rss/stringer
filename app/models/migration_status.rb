# frozen_string_literal: true

module MigrationStatus
  def self.call
    migrator = ActiveRecord::Base.connection.pool.migration_context.open

    migrator.pending_migrations.map do |migration|
      "#{migration.name} - #{migration.version}"
    end
  end
end
