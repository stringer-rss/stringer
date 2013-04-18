class Feed < ActiveRecord::Base
  has_many :stories, order: "published desc"
end