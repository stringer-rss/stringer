# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    system("pnpm build > /dev/null 2>&1", exception: true)
  end
end
