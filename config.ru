require "rubygems"
require "bundler"

Bundler.require

require "./fever_api"
require "./app"

map "/fever" do
  run FeverAPI
end

run Stringer