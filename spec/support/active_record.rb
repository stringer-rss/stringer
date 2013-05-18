require 'active_record'

config = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection(config['test'])

def need_to_migrate?
  current_migration = ActiveRecord::Migrator.current_version
  latest_migration = begin
    ActiveRecord::Migrator.get_all_versions.last
  rescue ActiveRecord::StatementInvalid
    nil
  end
  current_migration != latest_migration
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
