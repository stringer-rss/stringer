require "spec_helper"
require "support/active_record"

app_require "repositories/group_repository"

describe GroupRepository do
  describe ".list" do
    it "lists groups ordered by lower name" do
      group1 = create_group(name: "Zabba")
      group2 = create_group(name: "zlabba")
      group3 = create_group(name: "blabba")
      group4 = create_group(name: "Babba")
      expected_groups = [group4, group3, group1, group2]

      expect(GroupRepository.list).to eq(expected_groups)
    end
  end
end
