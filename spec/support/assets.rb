# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    system("pnpm build > /dev/null 2>&1", exception: true)
    system("pnpm build:css > /dev/null 2>&1", exception: true)
  end
end
