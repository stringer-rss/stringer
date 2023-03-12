# frozen_string_literal: true

require "thread/pool"

module Feed::FetchAll
  def self.call
    pool = Thread.pool(10)

    Feed.find_each { |feed| pool.process { Feed::FetchOne.call(feed) } }

    pool.shutdown
  end
end
