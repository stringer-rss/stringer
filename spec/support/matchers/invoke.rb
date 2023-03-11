# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

class Matchers::Invoke
  include RSpec::Matchers::Composable

  delegate :failure_message,
           :failure_message_when_negated,
           to: :received_matcher

  def initialize(expected_method)
    @expected_method = expected_method
  end

  def matches?(event_proc)
    raise(ArgumentError, "missing '.on'") unless defined?(@expected_recipient)

    allow(@expected_recipient).to receive(@expected_method)
    allow(@expected_recipient).to receive_expected

    event_proc.call
    received_matcher.matches?(@expected_recipient)
  end

  def on(expected_recipient)
    @expected_recipient = expected_recipient
    self
  end

  def with(*expected_arguments)
    @expected_arguments = expected_arguments
    self
  end

  def and_return(*return_arguments)
    @return_arguments = return_arguments
    self
  end

  def and_call_original
    @and_call_original = true
    self
  end

  def twice
    @times = 2
    self
  end

  def once
    @times = 1
    self
  end

  def supports_block_expectations?
    true
  end

  private

  def receive_expected
    receive_expected = receive(@expected_method)

    if defined?(@return_arguments)
      receive_expected = receive_expected.and_return(*@return_arguments)
    end

    if defined?(@and_call_original)
      receive_expected = receive_expected.and_call_original
    end

    receive_expected
  end

  def allow(target)
    RSpec::Mocks::AllowanceTarget.new(target)
  end

  def receive(method_name)
    RSpec::Mocks::Matchers::Receive.new(method_name, nil)
  end

  def received_matcher
    @received_matcher ||=
      begin
        matcher = RSpec::Mocks::Matchers::HaveReceived.new(@expected_method)

        if defined?(@expected_arguments)
          matcher = matcher.with(*@expected_arguments)
        end

        matcher = matcher.exactly(@times).times if defined?(@times)

        matcher
      end
  end
end
