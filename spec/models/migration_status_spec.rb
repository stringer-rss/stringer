require "spec_helper"
require "support/active_record"

app_require "models/migration_status"

describe "MigrationStatus" do
  describe "pending_migrations" do
    it "returns array of strings representing pending migrations" do
      migrator = double "Migrator"
      allow(migrator).to receive(:migrations).and_return [
        double("First Migration", name: "Migration A", version: 1),
        double("Second Migration", name: "Migration B", version: 2),
        double("Third Migration", name: "Migration C", version: 3)
      ]
      allow(migrator).to receive(:migrations_path)
      allow(migrator).to receive(:current_version).and_return 1

      expect(MigrationStatus.new(migrator).pending_migrations).to eq ["Migration B - 2", "Migration C - 3"]
    end
  end
end
