ruby "2.0.0"
source "https://rubygems.org"

group :production do
  gem "pg", "~> 0.17.1"
  gem "unicorn", "~> 4.7"
end

group :development do
  gem "sqlite3", "~> 1.3", ">= 1.3.8"
end

group :development, :test do
  gem "coveralls", "~> 0.7", require: false
  gem "faker", "~> 1.2"
  gem "foreman", "~> 0.63.0"
  gem "pry-byebug", "~> 1.2"
  gem "rack-test", "~> 0.6.2"
  gem "rspec", "~> 2.14", ">= 2.14.1"
  gem "rspec-html-matchers", "~> 0.4.3"
  gem "shotgun", "~> 0.9.0"
end

gem "activerecord", "~> 4.0"
# need to work around bug in 4.0.1 https://github.com/rails/arel/pull/216
gem 'arel', git: 'git://github.com/rails/arel.git', branch: '4-0-stable'
gem "bcrypt-ruby", "~> 3.1.2"
gem "delayed_job", "~> 4.0"
gem "delayed_job_active_record", "~> 4.0"
gem "feedbag", "~> 0.9.2"
gem "feedjira", "~> 1.3.0"
gem "highline", "~> 1.6", ">= 1.6.20", require: false
gem "i18n", "~> 0.6.9"
gem "loofah", "~> 2.0.0"
gem "nokogiri", "~> 1.6"
gem "racksh", "~> 1.0"
gem "rake", "~> 10.1", ">= 10.1.1"
gem "sinatra", "~> 1.4", ">= 1.4.4"
gem "sinatra-assetpack", "~> 0.3.1", require: "sinatra/assetpack"
gem "sinatra-activerecord", "~> 1.2", ">= 1.2.3"
gem "sinatra-contrib", ">= 1.4.2"
gem "sinatra-flash", "~> 0.3.0"
gem "thread", "~> 0.1.3"
gem "will_paginate", "~> 3.0", ">= 3.0.5"
