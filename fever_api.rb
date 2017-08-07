require "sinatra/base"
require "sinatra/activerecord"

require_relative "./app/fever_api/response"

module FeverAPI
  class Endpoint < Sinatra::Base
    configure do
      set :database_file, "config/database.yml"

      register Sinatra::ActiveRecordExtension
      ActiveRecord::Base.include_root_in_json = false
    end

    before do
      headers = { "Content-Type" => "application/json" }
      body = { api_version: FeverAPI::API_VERSION, auth: 0 }.to_json
      halt 200, headers, body unless authenticated?(params[:api_key])
    end

    def authenticated?(api_key)
      return unless api_key
      user = User.first
      user.api_key && api_key.casecmp(user.api_key).zero?
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
      FeverAPI::Response.new(params).to_json
    end
  end
end
