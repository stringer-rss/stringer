# frozen_string_literal: true

ruby_version_file = File.expand_path(".ruby-version", __dir__)
ruby File.read(ruby_version_file).chomp if File.readable?(ruby_version_file)
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dotenv-rails"

gem "rails", "~> 8.1.0"

gem "bcrypt"
gem "bootsnap", require: false
gem "feedbag"
gem "feedjira"
gem "good_job", "~> 4.12.0"
gem "httparty"
gem "nokogiri", "~> 1.18.0"
gem "pg"
gem "puma", "~> 7.0"
gem "rack-ssl"
gem "sass"
gem "sprockets"
gem "sprockets-rails"
gem "stripe"
gem "thread"
gem "uglifier"
gem "will_paginate"

group :development do
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "web-console"
end

group :development, :test do
  gem "capybara"
  gem "coveralls_reborn", require: false
  gem "debug"
  gem "factory_bot"
  gem "pry-byebug"
  gem "rspec"
  gem "rspec-rails"
  gem "simplecov"
  gem "webmock", require: false
end

group :test do
  gem "axe-core-rspec"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "with_model"
end
