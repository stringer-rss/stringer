# frozen_string_literal: true

class CallableJob < ApplicationJob
  def perform(callable, *, **)
    callable.call(*, **)
  end
end
