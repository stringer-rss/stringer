worker_processes 3
timeout 30
preload_app true

@delayed_job_pid = nil

before_fork do |server, worker|
  # the following is highly recommended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  @delayed_job_pid ||= spawn("bundle exec rake work_jobs")

  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    env = ENV['RACK_ENV'] || "development"
    config = YAML::load(File.open('config/database.yml'))[env]
    ActiveRecord::Base.establish_connection(config)
  end
end
