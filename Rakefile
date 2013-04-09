require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"

task :fetch_feeds do
  puts "fetch some feeds yo"
end

desc "Clear the delayed_job queue."
task :clear_jobs do
  Delayed::Job.delete_all
end

desc 'delayed_job worker process'
task :work_jobs do
  Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
end