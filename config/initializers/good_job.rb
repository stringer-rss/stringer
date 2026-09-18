# frozen_string_literal: true

Rails.application.configure do
  config.good_job.preserve_job_records = true
  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 14.days
  config.good_job.on_thread_error = ->(exception) { Rails.error.report(exception) }
end
