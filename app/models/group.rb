class Group < ActiveRecord::Base
  has_many :feeds

  def as_fever_json
    { id: id, title: name }
  end
end
