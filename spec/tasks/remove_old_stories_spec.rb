require 'spec_helper'
app_require 'tasks/remove_old_stories'

describe RemoveOldStories do
  describe '.remove!' do
    let(:stories_mock) { double('stories') }

    it 'should pass along the number of days to the story repository query' do
      StoryRepository.should_receive(:unstarred_read_stories_older_than).with(7).and_return(stories_mock)
      stories_mock.stub(:delete_all)

      RemoveOldStories.remove!(7)
    end

    it 'should request deletion of all old stories' do
      StoryRepository.should_receive(:unstarred_read_stories_older_than).and_return(stories_mock)
      stories_mock.should_receive(:delete_all)

      RemoveOldStories.remove!(11)
    end
  end
end
