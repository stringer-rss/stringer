# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require "active_support/core_ext/kernel/reporting"
require_relative "config/environment"

run Rails.application
Rails.application.load_server
