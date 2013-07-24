require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"
require_relative "./app/tasks/fetch_feeds"
require_relative "./app/tasks/change_password"
require_relative "./app/tasks/import_google_reader_stars"
require_relative "./app/tasks/remove_old_stories.rb"

desc "Fetch all feeds."
task :fetch_feeds do
  FetchFeeds.new(Feed.all).fetch_all
end

desc "Fetch single feed"
task :fetch_feed, :id do |t, args|
  FetchFeed.new(Feed.find(args[:id])).fetch
end

desc "Clear the delayed_job queue."
task :clear_jobs do
  Delayed::Job.delete_all
end

desc "Work the delayed_job queue."
task :work_jobs do
  Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
end

desc "Change your password"
task :change_password do
  ChangePassword.new.change_password
end

desc "Clean up old stories that are read and unstarred"
task :cleanup_old_stories, :number_of_days do |t, args|
  args.with_defaults(:number_of_days => 30)
  RemoveOldStories.remove!(args[:number_of_days].to_i)
end

desc "Import starred items from Google Reader starred.json"
task :import_google_reader_stars, :path do |t, args|
  ImportGoogleReaderStars.new(args[:path]).import_google_reader_stars
end

desc "Start server and serve JavaScript test suite at /test"
task :test_js do
  require_relative "./spec/javascript/test_controller"
  Stringer.run!
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:speedy_tests) do |t|
    t.rspec_opts = "--tag ~speed:slow"
  end

  RSpec::Core::RakeTask.new(:spec)

  task :default => [:speedy_tests]
rescue LoadError
  # allow for bundle install --without development:test
end

desc "deploy stringer on Heroku"
task :deploy do

  require 'excon'
  require 'formatador'
  require 'json'
  require 'netrc'
  require 'rendezvous'
  require 'securerandom'

  Formatador.display_line("[negative]<> deploying stringer to Heroku[/]")

  # grab netrc credentials, set by toolbelt via `heroku login`
  Formatador.display_line("[negative]<> reading your global Heroku credentials from ~/.netrc (set when you ran heroku login)...[/]")
  _, password = Netrc.read['api.heroku.com']

  # setup excon for API calls
  heroku = Excon.new(
    'https://api.heroku.com',
    :headers => {
      "Accept"        => "application/vnd.heroku+json; version=3",
      "Authorization" => "Basic #{[':' << password].pack('m').delete("\r\n")}",
      "Content-Type"  => "application/json"
    }
  )

  #heroku create
  Formatador.display_line("[negative]<> creating app[/]")
  app_data = JSON.parse(heroku.post(:path => "/apps").body)

  #git push heroku master
  Formatador.display_line("[negative]<> pushing code to [underline]#{app_data['name']}[/]")
  `git push git@heroku.com:#{app_data['name']}.git master`

  heroku.reset # reset socket as git push may take long enough for timeout

  #heroku config:set SECRET_TOKEN=`openssl rand -hex 20`
  Formatador.display_line("[negative]<> setting SECRET_TOKEN on [underline]#{app_data['name']}[/]")
  heroku.patch(
    :body       => { "SECRET_TOKEN" => SecureRandom.hex(20) }.to_json,
    :path       => "/apps/#{app_data['id']}/config-vars"
  )

  #heroku run rake db:migrate
  Formatador.display_line("[negative]<> running `rake db:migrate` on [underline]#{app_data['name']}[/]")
  run_data = JSON.parse(heroku.post(
    :body => {
      "attach"  => true,
      "command" => "rake db:migrate"
    }.to_json,
    :path => "/apps/#{app_data['id']}/dynos"
  ).body)
  Rendezvous.start(
    :url => run_data['attach_url']
  )

  heroku.reset # reset socket as db:migrate may take long enough for timeout

  #heroku restart
  Formatador.display_line("[negative]<> restarting [underline]#{app_data['name']}[/]")
  heroku.delete(:path => "/apps/#{app_data['id']}/dynos")

  #heroku addons:add scheduler
  Formatador.display_line("[negative]<> adding scheduler:standard to [underline]#{app_data['name']}[/]")
  heroku.post(
    :body => { "plan" => { "name" => "scheduler:standard" } }.to_json,
    :path => "/apps/#{app_data['id']}/addons"
  )

  #heroku addons:open scheduler
  Formatador.display_lines([
    "[negative]<> Add `[bold]rake fetch_feeds[/][negative]` hourly task at [underline]https://api.heroku.com/apps/#{app_data['id']}/addons/scheduler:standard[/]",
    "[negative]<> Impatient? After adding feeds, immediately fetch the latest with `heroku run rake fetch_feeds -a #{app_data['name']}`",
    "[negative]<> stringer available at [underline]#{app_data['web_url']}[/]"
  ])
end

desc "update stringer on heroku"
task :update, :app do |task, args|

  require 'excon'
  require 'formatador'
  require 'json'
  require 'netrc'
  require 'rendezvous'

  unless args.app
    Formatador.display_line("[negative]! Error: App required, please run as `bundle exec rake update[app]`[/]")
    exit
  end

  Formatador.display_line("[negative]<> updating Heroku stringer on [underline]#{args.app}[/]")

  # grab netrc credentials, set by toolbelt via `heroku login`
  Formatador.display_line("[negative]<> reading your global Heroku credentials from ~/.netrc (set when you ran heroku login)...[/]")
  _, password = Netrc.read['api.heroku.com']

  # setup excon for API calls
  heroku = Excon.new(
    'https://api.heroku.com',
    :headers => {
      "Accept"        => "application/vnd.heroku+json; version=3",
      "Authorization" => "Basic #{[':' << password].pack('m').delete("\r\n")}",
      "Content-Type"  => "application/json"
    }
  )

  #git push heroku master
  Formatador.display_line("[negative]<> pushing code to [underline]#{args.app}[/]")
  `git push git@heroku.com:#{args.app}.git master`

  #heroku run rake db:migrate
  Formatador.display_line("[negative]<> running `rake db:migrate` on [underline]#{args.app}[/]")
  run_data = JSON.parse(heroku.post(
    :body => {
      "attach"  => true,
      "command" => "rake db:migrate"
    }.to_json,
    :path => "/apps/#{args.app}/dynos"
  ).body)
  Rendezvous.start(
    :url => run_data['attach_url']
  )

  heroku.reset # reset socket as db:migrate may take long enough for timeout

  #heroku restart
  Formatador.display_line("[negative]<> restarting [underline]#{args.app}[/]")
  heroku.delete(:path => "/apps/#{args.app}/dynos")
end
