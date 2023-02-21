# frozen_string_literal: true

RSpec.describe Group do
  describe "#as_fever_json" do
    it "returns a hash of the group in fever format" do
      group = described_class.new(id: 5, name: "wat group")

      expect(group.as_fever_json).to eq(id: 5, title: "wat group")
    end
  end
end
