FactoryBot.define do
  factory(:feed) do
    sequence(:url, 100) { |n| "http://exampoo.com/#{n}" }
  end
end
