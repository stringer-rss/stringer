# frozen_string_literal: true

RSpec.describe CastBoolean do
  ["true", true, "1"].each do |true_value|
    it "returns true when passed #{true_value.inspect}" do
      expect(described_class.call(true_value)).to be(true)
    end
  end

  ["false", false, "0"].each do |false_value|
    it "returns false when passed #{false_value.inspect}" do
      expect(described_class.call(false_value)).to be(false)
    end
  end

  it "raises an error when passed non-boolean value" do
    ["butt", 0, nil, "", []].each do |bad_value|
      expected_message = "cannot cast to boolean: #{bad_value.inspect}"
      expect { described_class.call(bad_value) }
        .to raise_error(ArgumentError, expected_message)
    end
  end
end
