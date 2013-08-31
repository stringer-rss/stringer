require "rubygems"
require "bundler"

Bundler.require

require "./fever_api"
map "/fever" do
  run FeverAPI::Endpoint
end

require "./app"
run Stringer
