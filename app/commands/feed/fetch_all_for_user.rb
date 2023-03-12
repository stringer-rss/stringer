# frozen_string_literal: true

require "thread/pool"

module Feed::FetchAllForUser
  def self.call(user)
    pool = Thread.pool(10)

    user.feeds.find_each { |feed| pool.process { Feed::FetchOne.call(feed) } }

    pool.shutdown
  end
end
