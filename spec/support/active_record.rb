require 'active_record'

config = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(config['test'])

def need_to_migrate?
  ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations('db/migrate')).pending_migrations.any?
end

if need_to_migrate?
  ActiveRecord::Migrator.up "db/migrate"
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
