require_relative "factories/feed_factory"
require_relative "factories/story_factory"
require_relative "factories/user_factory"
require_relative "factories/group_factory"
require_relative "factories/feeds"
require_relative "factories/groups"
require_relative "factories/stories"
require_relative "factories/users"

module Factories
  def next_id
    @next_id ||= 0
    @next_id += 1
  end
end
