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
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(
      :adapter => 'postgresql',
      :encoding => 'unicode',
      :pool => 5,
      :database => ENV['STRINGER_DATABASE'] || "stringer",
      :username => ENV['STRINGER_DATABASE_USERNAME'],
      :password => ENV['STRINGER_DATABASE_PASSWORD']
    )
end
