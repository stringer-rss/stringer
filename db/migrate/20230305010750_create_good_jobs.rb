# frozen_string_literal: true

class CreateGoodJobs < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto"

    create_table :good_jobs, id: :uuid do |t|
      t.text :queue_name
      t.integer :priority
      t.jsonb :serialized_params
      t.datetime :scheduled_at
      t.datetime :performed_at
      t.datetime :finished_at
      t.text :error

      t.timestamps

      t.uuid :active_job_id
      t.text :concurrency_key
      t.text :cron_key
      t.uuid :retried_good_job_id
      t.datetime :cron_at

      t.uuid :batch_id
      t.uuid :batch_callback_id
    end

    create_table :good_job_batches, id: :uuid do |t|
      t.timestamps
      t.text :description
      t.jsonb :serialized_properties
      t.text :on_finish
      t.text :on_success
      t.text :on_discard
      t.text :callback_queue_name
      t.integer :callback_priority
      t.datetime :enqueued_at
      t.datetime :discarded_at
      t.datetime :finished_at
    end

    create_table :good_job_processes, id: :uuid do |t|
      t.timestamps
      t.jsonb :state
    end

    create_table :good_job_settings, id: :uuid do |t|
      t.timestamps
      t.text :key
      t.jsonb :value
      t.index :key, unique: true
    end

    add_index :good_jobs,
              :scheduled_at,
              where: "(finished_at IS NULL)",
              name: "index_good_jobs_on_scheduled_at"
    add_index :good_jobs,
              [:queue_name, :scheduled_at],
              where: "(finished_at IS NULL)",
              name: :index_good_jobs_on_queue_name_and_scheduled_at
    add_index :good_jobs,
              [:active_job_id, :created_at],
              name: :index_good_jobs_on_active_job_id_and_created_at
    add_index :good_jobs,
              :concurrency_key,
              where: "(finished_at IS NULL)",
              name: :index_good_jobs_on_concurrency_key_when_unfinished
    add_index :good_jobs,
              [:cron_key, :created_at],
              name: :index_good_jobs_on_cron_key_and_created_at
    add_index :good_jobs,
              [:cron_key, :cron_at],
              name: :index_good_jobs_on_cron_key_and_cron_at,
              unique: true
    add_index :good_jobs,
              [:active_job_id],
              name: :index_good_jobs_on_active_job_id
    add_index :good_jobs,
              [:finished_at],
              where: "retried_good_job_id IS NULL AND finished_at IS NOT NULL",
              name: :index_good_jobs_jobs_on_finished_at
    add_index :good_jobs,
              [:priority, :created_at],
              order: { priority: "DESC NULLS LAST", created_at: :asc },
              where: "finished_at IS NULL",
              name: :index_good_jobs_jobs_on_priority_created_at_when_unfinished
    add_index :good_jobs, [:batch_id], where: "batch_id IS NOT NULL"
    add_index :good_jobs,
              [:batch_callback_id],
              where: "batch_callback_id IS NOT NULL"
  end
end
