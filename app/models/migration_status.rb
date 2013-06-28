class MigrationStatus
  def pending_migrations
    migrations_path = ActiveRecord::Migrator.migrations_path
    migrations = ActiveRecord::Migrator.migrations(migrations_path)
    current_version = ActiveRecord::Migrator.current_version

    migrations.select do |m|
      current_version < m.version
    end.map do |m|
      "#{m.name} - #{m.version}"
    end
  end
end
