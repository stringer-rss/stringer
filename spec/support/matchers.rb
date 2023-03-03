# frozen_string_literal: true

module Matchers
  def change_all_records(records, attribute)
    Matchers::ChangeAllRecords.new(records, attribute)
  end

  def change_record(record, attribute)
    Matchers::ChangeRecord.new(record, attribute)
  end

  def delete_record(record)
    Matchers::DeleteRecord.new(record)
  end

  def invoke(expected_method)
    Matchers::Invoke.new(expected_method)
  end
end

RSpec.configure { |config| config.include(Matchers) }

RSpec::Matchers.define_negated_matcher(:not_change, :change)
RSpec::Matchers.define_negated_matcher(:not_change_record, :change_record)
RSpec::Matchers.define_negated_matcher(:not_delete_record, :delete_record)
RSpec::Matchers.define_negated_matcher(:not_raise_error, :raise_error)

Dir[File.join(__dir__, "./matchers/*.rb")].each { |path| require path }
