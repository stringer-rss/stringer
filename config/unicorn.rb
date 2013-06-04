worker_processes 3
timeout 30
preload_app true

@delayed_job_pid = nil

before_fork do |server, worker|
  @delayed_job_pid ||= spawn("bundle exec rake work_jobs")
  ActiveRecord::Base.establish_connection

  sleep 1
end