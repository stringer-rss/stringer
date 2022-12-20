# frozen_string_literal: true

require "spec_helper"
require "support/active_record"

app_require "repositories/group_repository"

describe GroupRepository do
  describe ".list" do
    it "lists groups ordered by lower name" do
      group1 = create(:group, name: "Zabba")
      group2 = create(:group, name: "zlabba")
      group3 = create(:group, name: "blabba")
      group4 = create(:group, name: "Babba")
      expected_groups = [group4, group3, group1, group2]

      expect(GroupRepository.list).to eq(expected_groups)
    end
  end
end
