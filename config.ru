# frozen_string_literal: true

require "rubygems"
require "bundler"

require "active_support/core_ext/kernel/reporting"
Bundler.require

require "./app"
run Stringer
