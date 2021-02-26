class AddDelayedJob < ActiveRecord::Migration[4.2]
  def self.up
    create_table :delayed_jobs, force: true do |table|
      # Allows some jobs to jump to the front of the queue
      table.integer :priority, default: 0

      # Provides for retries, but still fail eventually.
      table.integer :attempts, default: 0

      # YAML-encoded string of the object that will do work
      table.text :handler

      # reason for last failure (See Note below)
      table.text :last_error

      # When to run. Could be Time.zone.now for immediately, or sometime in the
      # future.
      table.datetime :run_at

      # Set when a client is working on this object
      table.datetime :locked_at

      # Set when all retries have failed (actually, by default, the record is
      # deleted instead)
      table.datetime :failed_at

      # Who is working on this object (if locked)
      table.string :locked_by

      # The name of the queue this job is in
      table.string :queue

      table.timestamps null: false
    end

    add_index :delayed_jobs, [:priority, :run_at], name: "delayed_jobs_priority"
  end

  def self.down
    drop_table :delayed_jobs
  end
end
