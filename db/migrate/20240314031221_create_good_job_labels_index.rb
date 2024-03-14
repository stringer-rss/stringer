# frozen_string_literal: true

class CreateGoodJobLabelsIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    reversible do |dir|
      dir.up do
        unless connection.index_name_exists?(:good_jobs, :index_good_jobs_on_labels)
          add_index :good_jobs, :labels, using: :gin, where: "(labels IS NOT NULL)",
            name: :index_good_jobs_on_labels, algorithm: :concurrently
        end
      end

      dir.down do
        if connection.index_name_exists?(:good_jobs, :index_good_jobs_on_labels)
          remove_index :good_jobs, name: :index_good_jobs_on_labels
        end
      end
    end
  end
end
