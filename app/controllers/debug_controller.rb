# frozen_string_literal: true

class DebugController < ApplicationController
  skip_before_action :complete_setup, only: [:heroku]
  skip_before_action :authenticate_user, only: [:heroku]

  def index
    authorization.skip
    render(
      Views::Debug::Index.new(
        queued_jobs_count: GoodJob::Job.queued.count,
        pending_migrations: MigrationStatus.call,
        user_agent: request.user_agent
      )
    )
  end

  def heroku
    authorization.skip
    render(Views::Debug::Heroku.new)
  end
end
