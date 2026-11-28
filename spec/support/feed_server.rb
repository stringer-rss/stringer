# frozen_string_literal: true

class FeedServer
  attr_writer :response, :delay

  def initialize
    @server = Capybara::Server.new(method(:response)).boot
  end

  # `delay` (seconds) holds the response, for specs that check a loading state.
  def response(_env)
    sleep(@delay) if @delay
    [200, {}, [@response]]
  end

  def url
    "http://#{@server.host}:#{@server.port}"
  end
end
