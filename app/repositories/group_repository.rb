require_relative "../models/group"

class GroupRepository
  def self.list
    Group.order(Group.arel_table[:name].lower)
  end
end
