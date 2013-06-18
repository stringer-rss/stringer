class DropEmailFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :email
  end
end
