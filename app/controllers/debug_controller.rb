require_relative "../models/migration_status"

class Stringer < Sinatra::Base
  get "/debug" do
    erb :debug, locals: {
      queued_jobs_count: Delayed::Job.count,
      pending_migrations: MigrationStatus.new.pending_migrations
    }
  end

  get "/heroku" do
    erb :heroku
  end
end
