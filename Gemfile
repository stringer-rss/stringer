ruby_version_file = File.expand_path(".ruby-version", __dir__)
ruby File.read(ruby_version_file).chomp if File.readable?(ruby_version_file)
source "https://rubygems.org"

group :production do
  gem "pg", "~> 0.18.4"
  gem "unicorn", "~> 5.3"
end

group :development do
  gem "rubocop", require: false
  gem "sqlite3"
end

group :development, :test do
  gem "capybara"
  gem "coveralls", "> 0.8", require: false
  gem "faker"
  gem "pry-byebug"
  gem "rack-test"
  gem "rspec"
  gem "rspec-html-matchers"
  gem "shotgun"
  gem "simplecov"
  gem "timecop"
end

gem "activerecord", "~> 5.0"
gem "bcrypt", "~> 3.1"
gem "delayed_job", "~> 4.1"
gem "delayed_job_active_record", "~> 4.1"
gem "feedbag", "~> 0.9.5"
gem "feedjira", "~> 3.0"
gem "httparty"
gem "i18n"
gem "loofah", "~> 2.3"
gem "nokogiri", "~> 1.11"
gem "rack-protection", "~> 2.0"
gem "racksh", "~> 1.0"
gem "rack-ssl", "~> 1.4"
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
