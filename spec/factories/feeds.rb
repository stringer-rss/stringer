# frozen_string_literal: true

FactoryBot.define do
  factory(:feed) do
    sequence(:name, 100) { |n| "Feed #{n}" }
    sequence(:url, 100) { |n| "http://exampoo.com/#{n}" }
  end
end
