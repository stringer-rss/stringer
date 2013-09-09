source "https://rubygems.org"
ruby '1.9.3'

group :production do
  gem "unicorn", "~> 4.6.2"
  gem "pg", "~> 0.15.1"
end

group :development do
  gem "sqlite3", "~> 1.3.7"
  gem "coveralls", "~> 0.6.7", require: false
  gem "pry-debugger", "~> 0.2.2"
  gem "rspec", "~> 2.13.0"
  gem "rspec-html-matchers", "~> 0.4.1"
  gem "rack-test", "~> 0.6.2"
  gem "shotgun", "~> 0.9"
  gem "faker", "~> 1.1.2"
  gem "foreman", "~> 0.63.0"
end

group :test do
  gem "coveralls", "~> 0.6.7", require: false
  gem "pry-debugger", "~> 0.2.2"
  gem "rspec", "~> 2.13.0"
  gem "rspec-html-matchers", "~> 0.4.1"
  gem "rack-test", "~> 0.6.2"
  gem "shotgun", "~> 0.9"
  gem "racksh", "~> 1.0.0"
  gem "faker", "~> 1.1.2"
  gem "foreman", "~> 0.63.0"
end

group :heroku do
  gem "excon", "~> 0.25.0"
  gem "formatador", "~> 0.2.4"
  gem "netrc", "~> 0.7.7"
  gem "rendezvous", "~> 0.0.2"
end

gem "sinatra", "~> 1.4.2"
gem "activerecord", "~> 3.2.0"
gem "sinatra-activerecord", "~> 1.2.2"
gem "sinatra-flash", "~> 0.3.0"
gem "sinatra-contrib", github: "sinatra/sinatra-contrib"
gem "sinatra-assetpack", "~> 0.2.2", require: "sinatra/assetpack"
gem "i18n", "~> 0.6.4"
gem "rake", "~> 10.0.4"
gem "delayed_job_active_record", "~> 0.4.4"
gem "bcrypt-ruby", "~> 3.0.1"
gem "will_paginate", "~> 3.0.4"
gem "feedzirra", github: "swanson/feedzirra"
gem "loofah", github: "swanson/loofah"
gem "nokogiri", "~> 1.5.9"
gem "feedbag", github: "dwillis/feedbag"
gem "highline", "~> 1.6.19", require: false
gem "thread", "~> 0.0.8"
gem "racksh", "~> 1.0.0"
