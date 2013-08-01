require "sinatra/base"
require "sinatra/activerecord"

require_relative "fever_response.rb"

class FeverAPI < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"

    register Sinatra::ActiveRecordExtension
    ActiveRecord::Base.include_root_in_json = false
  end

  before do
    halt 403 unless authenticated?(params[:api_key])
  end

  def authenticated?(api_key)
    if api_key
      user = User.first
      user.api_key && api_key.downcase == user.api_key.downcase
    end
  end

  get "/" do
    content_type :json
    build_response(params)
  end

  post "/" do
    content_type :json
    build_response(params)
  end

  def build_response(params)
    Fever::Response.new(params).to_json
  end
end

