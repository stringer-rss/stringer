worker_processes 1
timeout 30
preload_app true

@delayed_job_pid = nil

before_fork do |_server, _worker|
  # the following is highly recommended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  @delayed_job_pid ||= spawn("bundle exec rake work_jobs")

  sleep 1
end

after_fork do |_server, _worker|
  if defined?(ActiveRecord::Base)
    env = ENV['RACK_ENV'] || "development"
    config = YAML::load(ERB.new(File.read('config/database.yml')).result)[env]
    ActiveRecord::Base.establish_connection(config)
  end
end
