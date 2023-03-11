# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :user
  has_many :feeds

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  def as_fever_json
    { id:, title: name }
  end
end
