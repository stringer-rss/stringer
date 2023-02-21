# frozen_string_literal: true

RSpec.describe GroupRepository do
  describe ".list" do
    it "lists groups ordered by lower name" do
      group1 = create(:group, name: "Zabba")
      group2 = create(:group, name: "zlabba")
      group3 = create(:group, name: "blabba")
      group4 = create(:group, name: "Babba")
      expected_groups = [group4, group3, group1, group2]

      expect(described_class.list).to eq(expected_groups)
    end
  end
end
