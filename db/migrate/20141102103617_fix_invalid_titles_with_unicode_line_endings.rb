class FixInvalidTitlesWithUnicodeLineEndings < ActiveRecord::Migration
  def up
    Story.find_each do |story|
      unless story.title.nil?
        valid_title = story.title.delete("\u2028").delete("\u2029")
        story.update_attribute(:title, valid_title)
      end
    end
  end

  def down
    # skip
  end
end
