class Feed < ActiveRecord::Base
  has_many :stories, order: "published desc"

  def status
    options = [:green, :yellow, :red]
    options[rand(3)]
  end
end