class AddSuperfeedrToUser < ActiveRecord::Migration
  def change
    
    add_column :users, :superfeedr_host, :string
    add_column :users, :superfeedr_username, :string
    add_column :users, :superfeedr_password, :string

  end
end
