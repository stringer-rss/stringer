require 'spec_helper'
app_require 'tasks/remove_old_stories'

describe RemoveOldStories do
  describe '.remove!' do
    let(:stories_mock) do
      stories = double('stories')
      stories.stub(:delete_all)
      stories
    end

    it 'should pass along the number of days to the story repository query' do
      RemoveOldStories.stub(:pruned_feeds){ [] }

      StoryRepository.should_receive(:unstarred_read_stories_older_than).with(7).and_return(stories_mock)

      RemoveOldStories.remove!(7)
    end

    it 'should request deletion of all old stories' do
      RemoveOldStories.stub(:pruned_feeds){ [] }
      StoryRepository.stub(:unstarred_read_stories_older_than){ stories_mock }

      stories_mock.should_receive(:delete_all)

      RemoveOldStories.remove!(11)
    end

    it 'should fetch affected feeds by id' do
      RemoveOldStories.stub(:old_stories) do
        stories = [double('story', feed_id: 3), double('story', feed_id: 5)]
        stories.stub(:delete_all)
        stories
      end

      FeedRepository.should_receive(:fetch_by_ids).with([3, 5]).and_return([])

      RemoveOldStories.remove!(13)
    end

    it 'should update last_fetched on affected feeds' do
      feeds = [double('feed a'), double('feed b')]
      RemoveOldStories.stub(:pruned_feeds){ feeds }
      RemoveOldStories.stub(:old_stories){ stories_mock }

      FeedRepository.should_receive(:update_last_fetched).with(feeds.first, anything())
      FeedRepository.should_receive(:update_last_fetched).with(feeds.last, anything())

      RemoveOldStories.remove!(13)
    end
  end
end
