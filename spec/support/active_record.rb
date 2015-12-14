require 'active_record'

db_config = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config['test'])
ActiveRecord::Base.logger = Logger.new('log/test.log')

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
