# frozen_string_literal: true

class FixInvalidTitlesWithUnicodeLineEndings < ActiveRecord::Migration[4.2]
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
