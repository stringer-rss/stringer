# frozen_string_literal: true

class Matchers::ChangeRecord
  include RSpec::Matchers::Composable

  attr_reader :record,
              :attribute,
              :original_value,
              :new_value,
              :expected_new_value,
              :expected_original_value

  def initialize(record, attribute)
    @record = record
    @attribute = attribute
    @expected_original_value = :__not_set__
    @expected_new_value = :__not_set__
  end

  def supports_block_expectations?
    true
  end

  def matches?(event_proc)
    perform_change(event_proc)

    original_value_matches? && changed? && new_value_matches?
  end

  def from(expected_original_value)
    @expected_original_value = expected_original_value
    self
  end

  def does_not_match?(event_proc)
    if new_value_expected?
      message = "`expect { }.not_to change_record().to()` is not supported"

      raise(NotImplementedError, message)
    end

    perform_change(event_proc)

    original_value_matches? && !changed?
  end

  def to(expected_new_value)
    @expected_new_value = expected_new_value
    self
  end

  def failure_message
    if !original_value_matches?
      original_value_does_not_match_message
    elsif !changed?
      value_did_not_change_message
    else # new value doesn't match
      new_value_does_not_match_message
    end
  end

  def failure_message_when_negated
    if original_value_matches? # record changed
      value_changed_message
    else
      original_value_does_not_match_message
    end
  end

  private

  def perform_change(event_proc)
    @original_value = record[attribute]

    event_proc.call

    @new_value = record.reload.public_send(attribute)
  end

  def original_value_does_not_match_message
    <<~MESSAGE.squish
      expected original value to be #{expected_original_value} but was
      #{original_value}
    MESSAGE
  end

  def value_did_not_change_message
    if new_value_expected?
      <<~MESSAGE.squish
        expected value to change from #{original_value} to
        #{expected_new_value} but did not change
      MESSAGE
    else
      <<~MESSAGE.squish
        expected value to change from #{original_value} but did not change
      MESSAGE
    end
  end

  def new_value_does_not_match_message
    <<~MESSAGE.squish
      expected value to change to #{expected_new_value} but changed to
      #{new_value}
    MESSAGE
  end

  def value_changed_message
    <<~MESSAGE.squish
      expected value not to change from #{original_value} but changed to
      #{new_value}
    MESSAGE
  end

  def original_value_matches?
    !original_value_expected? || original_value == expected_original_value
  end

  def original_value_expected?
    expected_original_value != :__not_set__
  end

  def changed?
    new_value != original_value
  end

  def new_value_matches?
    !new_value_expected? || new_value == expected_new_value
  end

  def new_value_expected?
    expected_new_value != :__not_set__
  end
end
