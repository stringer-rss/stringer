# frozen_string_literal: true

class GroupRepository
  def self.list
    Group.order(Group.arel_table[:name].lower)
  end
end
