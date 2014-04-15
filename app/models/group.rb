class Group < ActiveRecord::Base
  has_many :feeds

  def as_fever_json
    { id: self.id, title: self.name }
  end
end
