# frozen_string_literal: true

class DropDelayedJob < ActiveRecord::Migration[7.0]
  def up
    drop_table :delayed_jobs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
