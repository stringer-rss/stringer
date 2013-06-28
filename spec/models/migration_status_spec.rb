require "spec_helper"
require "support/active_record"

app_require "models/migration_status"

describe "MigrationStatus" do
  describe "pending_migrations" do
    it "returns array of strings representing pending migrations" do
      ActiveRecord::Migrator.stub(:migrations).and_return [
        ActiveRecord::MigrationProxy.new("Migration A", 1, nil, nil),
        ActiveRecord::MigrationProxy.new("Migration B", 2, nil, nil),
        ActiveRecord::MigrationProxy.new("Migration C", 3, nil, nil)
      ]
      ActiveRecord::Migrator.stub(:migrations_path)
      ActiveRecord::Migrator.stub(:current_version).and_return 1
      
      MigrationStatus.new.pending_migrations.should eq ["Migration B - 2", "Migration C - 3"]
    end
  end
end
