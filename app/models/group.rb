# frozen_string_literal: true

require_relative "./application_record"

class Group < ApplicationRecord
  belongs_to :user
  has_many :feeds

  def as_fever_json
    { id:, title: name }
  end
end
