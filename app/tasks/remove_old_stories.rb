class RemoveOldStories
  def self.remove!(number_of_days)
    StoryRepository.unstarred_read_stories_older_than(number_of_days)
      .delete_all
  end
end
