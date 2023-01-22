# frozen_string_literal: true

require_relative "../models/migration_status"

class DebugController < ApplicationController
  skip_before_action :complete_setup, only: [:heroku]
  skip_before_action :authenticate_user, only: [:heroku]

  def index
    render(
      locals: {
        queued_jobs_count: Delayed::Job.count,
        pending_migrations: MigrationStatus.new.pending_migrations
      }
    )
  end

  def heroku; end
end
