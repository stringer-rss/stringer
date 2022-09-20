require "rubygems"
require "bundler"

require "active_support/core_ext/kernel/reporting"
Bundler.require

require "./fever_api"
map "/fever" do
  run FeverAPI::Endpoint
end

require "./app"
run Stringer
