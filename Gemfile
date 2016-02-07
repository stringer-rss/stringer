ruby_version_file = File.join(File.expand_path("..", __FILE__), ".ruby-version")
ruby File.read(ruby_version_file).chomp if File.readable?(ruby_version_file)
source "https://rubygems.org"

group :production do
  gem "pg", "~> 0.17.1"
  gem "unicorn", "~> 4.7"
end

group :development do
  gem "sqlite3", "~> 1.3", ">= 1.3.8"
end

group :development, :test do
  gem "capybara", "~> 2.4.1"
  gem "coveralls", "~> 0.7", require: false
  gem "faker", "~> 1.2"
  gem "pry-byebug", "~> 1.2"
  gem "rack-test", "~> 0.6.2"
  gem "rspec", "~> 3.4"
  gem "rspec-html-matchers", "~> 0.7"
  gem "rubocop", "~> 0.35.1", require: false
  gem "shotgun", "~> 0.9.0"
  gem "timecop", "~> 0.7.1"
end

gem "activerecord", "~> 4.1.11"
gem "arel", "~> 5.0"
gem "bcrypt-ruby", "~> 3.1.2"
gem "delayed_job", "~> 4.1"
gem "delayed_job_active_record", "~> 4.1"
gem "feedbag", "~> 0.9.2"
gem "feedjira", "~> 1.3.0"
gem "i18n", "~> 0.6.9"
gem "loofah", "~> 2.0.0"
gem "nokogiri", "~> 1.6", ">= 1.6.7.2"
gem "rack-ssl", "~> 1.4.1"
gem "racksh", "~> 1.0"
gem "rake", "~> 10.1", ">= 10.1.1"
gem "sinatra", "~> 1.4", ">= 1.4.4"
gem "sinatra-activerecord", "~> 1.2", ">= 1.2.3"
gem "sinatra-assetpack", "~> 0.3.1", require: "sinatra/assetpack"
gem "sinatra-contrib", ">= 1.4.2"
gem "sinatra-flash", "~> 0.3.0"
gem "thread", "~> 0.1.3"
gem "will_paginate", "~> 3.0", ">= 3.0.5"
gem "rack-protection", "~> 1.5.3"
