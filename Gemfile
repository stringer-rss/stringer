ruby_version_file = File.expand_path(".ruby-version", __dir__)
ruby File.read(ruby_version_file).chomp if File.readable?(ruby_version_file)
source "https://rubygems.org"

group :production do
  gem "pg", "~> 0.18.4"
  gem "unicorn", "~> 5.3"
end

group :development do
  gem "rubocop", ">= 0.61.1", require: false
  gem "sqlite3", "~> 1.3", ">= 1.3.8"
end

group :development, :test do
  gem "capybara", "~> 2.6"
  gem "coveralls", "~> 0.7", require: false
  gem "faker", "~> 1.2"
  gem "pry-byebug", "~> 1.2"
  gem "rack-test", "~> 1.1"
  gem "rspec", "~> 3.4"
  gem "rspec-html-matchers", "~> 0.7"
  gem "shotgun", "~> 0.9"
  gem "simplecov"
  gem "timecop", "~> 0.8"
end

gem "activerecord", "~> 4.2.6"
gem "bcrypt", "~> 3.1"
gem "delayed_job", "~> 4.1"
gem "delayed_job_active_record", "~> 4.1"
gem "feedbag", "~> 0.9.5"
gem "feedjira", "~> 2.1.3"
gem "i18n"
gem "loofah", "~> 2.3"
gem "nokogiri", "~> 1.11"
gem "rack-protection", "~> 2.0"
gem "rack-ssl", "~> 1.4"
gem "racksh", "~> 1.0"
gem "rake", "~> 12.3"
gem "sass"
gem "sinatra", "~> 2.0"
gem "sinatra-activerecord", "~> 2.0"
gem "sinatra-contrib", "~> 2.0"
gem "sinatra-flash", "~> 0.3"
gem "sprockets", "~> 3.7"
gem "sprockets-helpers"
gem "thread", "~> 0.2"
gem "uglifier"
gem "will_paginate", "~> 3.1"
