# frozen_string_literal: true

class CallableJob < ApplicationJob
  def perform(callable, *args, **kwargs)
    callable.call(*args, **kwargs)
  end
end
