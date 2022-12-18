require "spec_helper"
require "support/active_record"

app_require "models/migration_status"

describe "MigrationStatus" do
  describe "pending_migrations" do
    it "returns array of strings representing pending migrations" do
      migrator = ActiveRecord::Base.connection.migration_context.open

      allow(migrator).to receive(:pending_migrations).and_return(
        [
          ActiveRecord::Migration.new("Migration B", 2),
          ActiveRecord::Migration.new("Migration C", 3)
        ]
      )

      expect(MigrationStatus.new(migrator).pending_migrations)
        .to eq(["Migration B - 2", "Migration C - 3"])
    end
  end
end
