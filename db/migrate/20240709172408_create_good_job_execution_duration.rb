# frozen_string_literal: true

class CreateGoodJobExecutionDuration < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.column_exists?(:good_job_executions, :duration)
      end
    end

    add_column :good_job_executions, :duration, :interval
  end
end
