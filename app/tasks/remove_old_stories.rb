class RemoveOldStories
  def initialize(number_of_stories = 1000)
    @number_of_stories = number_of_stories
  end

  def remove!
    StoryRepository.oldest_read_stories(@number_of_stories)
      .each(&:delete)
  end
end
