ruby_version_file = File.join(File.expand_path("..", __FILE__), ".ruby-version")
ruby File.read(ruby_version_file).chomp if File.readable?(ruby_version_file)
source "https://rubygems.org"

group :production do
  gem "pg", "~> 0.18.4"
  gem "unicorn", "~> 4.7"
end

group :development do
  gem "sqlite3", "~> 1.3", ">= 1.3.8"
end

group :development, :test do
  gem "capybara", "~> 2.6"
  gem "coveralls", "~> 0.7", require: false
  gem "faker", "~> 1.2"
  gem "pry-byebug", "~> 1.2"
  gem "rack-test", "~> 0.6"
  gem "rspec", "~> 3.4"
  gem "rspec-html-matchers", "~> 0.7"
  gem "rubocop", "~> 0.38", require: false
  gem "shotgun", "~> 0.9"
  gem "timecop", "~> 0.8"
end

gem "activerecord", "~> 4.2.6"
gem "bcrypt", "~> 3.1"
gem "delayed_job", "~> 4.1"
gem "delayed_job_active_record", "~> 4.1"
gem "feedbag", "~> 0.9.5"
gem "feedjira", "~> 1.6"
gem "i18n"
gem "loofah", "~> 2.0"
gem "nokogiri", "~> 1.6", ">= 1.6.7.2"
gem "rack-ssl", "~> 1.4"
gem "racksh", "~> 1.0"
gem "rake", "~> 10.1", ">= 10.1.1"
gem "sinatra", "~> 1.4", ">= 1.4.4"
gem "sinatra-activerecord", "~> 1.2", ">= 1.2.3"
gem "sinatra-assetpack", "~> 0.3", require: "sinatra/assetpack"
gem "sinatra-contrib", "~> 1.4"
gem "sinatra-flash", "~> 0.3"
gem "thread", "~> 0.2"
gem "will_paginate", "~> 3.1"
gem "rack-protection", "~> 1.5"
