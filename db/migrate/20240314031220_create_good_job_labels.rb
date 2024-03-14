# frozen_string_literal: true

class CreateGoodJobLabels < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.column_exists?(:good_jobs, :labels)
      end
    end

    add_column :good_jobs, :labels, :text, array: true
  end
end
