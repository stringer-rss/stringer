# frozen_string_literal: true

class Matchers::ChangeAllRecords
  include RSpec::Matchers::Composable

  attr_reader :records,
              :attribute,
              :original_values,
              :new_values,
              :expected_new_value,
              :expected_original_value

  def initialize(records, attribute)
    @records = records
    @attribute = attribute
    @expected_original_value = :__not_set__
    @expected_new_value = :__not_set__
  end

  def supports_block_expectations?
    true
  end

  def matches?(event_proc)
    perform_change(event_proc)

    original_values_match? && changed? && new_values_match?
  end

  def from(expected_original_value)
    @expected_original_value = expected_original_value
    self
  end

  def does_not_match?(event_proc)
    if new_values_expected?
      message = "`expect { }.not_to change_all_records().to()` not supported"

      raise(NotImplementedError, message)
    end

    perform_change(event_proc)

    original_values_match? && !changed?
  end

  def to(expected_new_value)
    @expected_new_value = expected_new_value
    self
  end

  def failure_message
    if !original_values_match?
      original_values_do_not_match_message
    elsif !changed?
      values_did_not_change_message
    else
      new_values_do_not_match_message
    end
  end

  def failure_message_when_negated
    if original_values_match? # records changed
      values_changed_message
    else
      original_values_do_not_match_message
    end
  end

  private

  def perform_change(event_proc)
    @original_values = records.map { |record| record.public_send(attribute) }

    event_proc.call

    @new_values = records.map { |record| record.reload.public_send(attribute) }
  end

  def original_values_do_not_match_message
    <<~MESSAGE.squish
      expected original values to be #{expected_original_value} but were
      #{original_values}
    MESSAGE
  end

  def values_did_not_change_message
    if new_values_expected?
      <<~MESSAGE.squish
        expected values to change from #{original_values} to
        #{expected_new_value} but did not change
      MESSAGE
    else
      <<~MESSAGE.squish
        expected values to change from #{original_values} but did not change
      MESSAGE
    end
  end

  def new_values_do_not_match_message
    <<~MESSAGE.squish
      expected values to change to #{expected_new_value} but changed to
      #{new_values}
    MESSAGE
  end

  def values_changed_message
    <<~MESSAGE.squish
      expected values not to change from #{original_values} but changed to
      #{new_values}
    MESSAGE
  end

  def original_values_match?
    !original_value_expected? || original_values.all?(expected_original_value)
  end

  def original_value_expected?
    expected_original_value != :__not_set__
  end

  def changed?
    new_values != original_values
  end

  def new_values_match?
    !new_values_expected? || new_values.all?(expected_new_value)
  end

  def new_values_expected?
    expected_new_value != :__not_set__
  end
end
