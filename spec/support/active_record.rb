require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "db/stringer_test.sqlite"
ActiveRecord::Migrator.up "db/migrate"

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
