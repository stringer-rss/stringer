require_relative "../repositories/feed_repository"

module FeverAPI
  class ReadFeeds
    def call(params)
      if params.keys.include?('feeds')
        { feeds: feeds }
      else
        {}
      end
    end

    private

    def feeds
      FeedRepository.list.map{|f| f.as_fever_json}
    end
  end
end
