class MigrationStatus
  attr_reader :migrator

  def initialize(migrator=ActiveRecord::Migrator)
    @migrator = migrator
  end

  def pending_migrations
    migrations_path = migrator.migrations_path
    migrations = migrator.migrations(migrations_path)
    current_version = migrator.current_version

    migrations.select do |m|
      current_version < m.version
    end.map do |m|
      "#{m.name} - #{m.version}"
    end
  end
end
