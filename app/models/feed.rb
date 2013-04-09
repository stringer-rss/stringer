class Feed < ActiveRecord::Base
  has_many :stories
end