class RemoveOldStories
  def initialize(number_of_days)
    @number_of_days = number_of_days
  end

  def remove!
    StoryRepository.unstarred_read_stories_older_than(@number_of_days)
      .delete_all
  end
end
