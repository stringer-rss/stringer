# frozen_string_literal: true

RSpec.describe "MigrationStatus" do
  it "returns array of strings representing pending migrations" do
    migrator = ActiveRecord::Base.connection.pool.migration_context.open

    allow(migrator).to receive(:pending_migrations).and_return(
      [
        ActiveRecord::Migration.new("Migration B", 2),
        ActiveRecord::Migration.new("Migration C", 3)
      ]
    )
    allow(ActiveRecord::Migrator).to receive(:new).and_return(migrator)

    expect(MigrationStatus.call).to eq(["Migration B - 2", "Migration C - 3"])
  end
end
