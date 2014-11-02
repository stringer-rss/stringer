class FixInvalidTitlesWithUnicodeLineEndings < ActiveRecord::Migration
  def up
    Story.find_each do |story|
      valid_title = story.title.gsub("\u2028", '').gsub("\u2029", '')
      story.update_attribute(:title, valid_title)
    end
  end

  def down
    # skip
  end
end
