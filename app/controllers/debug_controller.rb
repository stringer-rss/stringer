# frozen_string_literal: true

class DebugController < ApplicationController
  skip_before_action :complete_setup, only: [:heroku]
  skip_before_action :authenticate_user, only: [:heroku]

  def index
    authorization.skip
    render(
      locals: {
        queued_jobs_count: GoodJob::Job.queued.count,
        pending_migrations: MigrationStatus.call
      }
    )
  end

  def heroku
    authorization.skip
  end
end
