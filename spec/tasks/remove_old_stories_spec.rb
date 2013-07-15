require 'spec_helper'
app_require 'tasks/remove_old_stories'

describe RemoveOldStories do

  before :each do
    @arel_mock = double('arel')
    @arel_mock.stub(:delete_all) { 0 }
    StoryRepository.stub(:unstarred_read_stories_older_than) { @arel_mock }
  end

  describe '.remove!' do
    it 'should pass along the number of days to the story repository query' do
      StoryRepository.should_receive(:unstarred_read_stories_older_than).with(7)
      RemoveOldStories.remove!(7)

    end

    it 'should call delete_all on the returned relation' do
      @arel_mock.should_receive(:delete_all)
      RemoveOldStories.remove!(7)
    end
  end
end