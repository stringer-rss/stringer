# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :type, presence: true, uniqueness: true
end
