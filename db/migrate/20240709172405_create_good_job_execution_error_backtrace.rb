# frozen_string_literal: true

class CreateGoodJobExecutionErrorBacktrace < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        if connection.column_exists?(:good_job_executions, :error_backtrace)
          return
        end
      end
    end

    add_column :good_job_executions, :error_backtrace, :text, array: true
  end
end
