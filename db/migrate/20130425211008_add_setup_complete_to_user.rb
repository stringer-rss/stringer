class AddSetupCompleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :setup_complete, :boolean
  end
end
