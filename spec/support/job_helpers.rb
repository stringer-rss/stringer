# frozen_string_literal: true

module JobHelpers
  def with_test_adapter
    adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test

    yield
  ensure
    ActiveJob::Base.queue_adapter = adapter
  end
end
