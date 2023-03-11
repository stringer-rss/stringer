# frozen_string_literal: true

require "factory_bot"
FactoryBot.find_definitions

module FactoryCache
  def self.user
    @user ||= FactoryBot.create(:user)
  end

  def self.reset
    @user = nil
  end
end

RSpec.configure do |config|
  config.include(FactoryBot::Syntax::Methods)

  config.after do
    FactoryBot.rewind_sequences
    FactoryCache.reset
  end
end

module FactoryBot::Syntax::Methods
  def default_user
    FactoryCache.user
  end
end
