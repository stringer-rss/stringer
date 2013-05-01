require "feedbag"
require "feedzirra"


class AddNewFeed
  ONE_DAY = 24 * 60 * 60

  def self.add(url, finder = Feedbag, parser = Feedzirra::Feed, repo = Feed)
    results = finder.find(url)

    return false if results.empty?
    
    result = parser.fetch_and_parse(results.first)

    repo.create(name: result.title,
                url: result.feed_url,
                last_fetched: Time.now - ONE_DAY)
  end
end