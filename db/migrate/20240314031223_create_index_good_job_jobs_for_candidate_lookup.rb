# frozen_string_literal: true

class CreateIndexGoodJobJobsForCandidateLookup < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.index_name_exists?(:good_jobs, :index_good_job_jobs_for_candidate_lookup)
      end
    end

    add_index :good_jobs, [:priority, :created_at], order: { priority: "ASC NULLS LAST", created_at: :asc },
      where: "finished_at IS NULL", name: :index_good_job_jobs_for_candidate_lookup,
      algorithm: :concurrently
  end
end
