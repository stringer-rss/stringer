# frozen_string_literal: true

module Matchers
  class DeleteRecord
    include RSpec::Matchers::Composable

    attr_reader :record

    def initialize(record)
      @record = record
    end

    def supports_block_expectations?
      true
    end

    def matches?(event_proc)
      perform_change(event_proc)

      exists_before? && !exists_after?
    end

    def does_not_match?(event_proc)
      perform_change(event_proc)

      exists_before? && exists_after?
    end

    def failure_message
      if exists_before? # was not deleted
        existed_after_message
      else
        did_not_exist_before_message
      end
    end

    def failure_message_when_negated
      if exists_before? # was deleted
        did_not_exist_after_message
      else
        did_not_exist_before_message
      end
    end

    private

    def perform_change(event_proc)
      @exists_before = record.class.exists?(record.id)

      event_proc.call

      @exists_after = record.class.exists?(record.id)
    end

    def did_not_exist_before_message
      <<~MESSAGE.squish
        expected #{record.class.name} with id #{record.id} to originally exist,
        but did not
      MESSAGE
    end

    def existed_after_message
      <<~MESSAGE.squish
        expected #{record.class.name} with id #{record.id} to be deleted,
        but was not deleted
      MESSAGE
    end

    def did_not_exist_after_message
      <<~MESSAGE.squish
        expected #{record.class.name} with id #{record.id} not to be deleted,
        but was deleted
      MESSAGE
    end

    def exists_before?
      @exists_before
    end

    def exists_after?
      @exists_after
    end
  end
end
