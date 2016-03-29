worker_processes 1
timeout 30
preload_app true

work_pids = {}

before_fork do |_server, _worker|
  # the following is highly recommended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  unless ENV["WORKER_EMBEDDED"] == "false"
    work_pids[:delayed_job] ||= spawn("bundle exec rake work_jobs")
    work_pids[:recurring_jobs] ||= spawn("bundle exec clockwork lib/clock.rb")
  end

  sleep 1
end

after_fork do |_server, _worker|
  if defined?(ActiveRecord::Base)
    env = ENV["RACK_ENV"] || "development"
    config = YAML.load(ERB.new(File.read("config/database.yml")).result)[env]
    ActiveRecord::Base.establish_connection(config)
  end
end
