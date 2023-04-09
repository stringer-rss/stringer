# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.references :user,
                   foreign_key: true,
                   null: false,
                   index: { unique: true }
      t.text :stripe_customer_id, null: false
      t.text :stripe_subscription_id, null: false
      t.text :status, null: false
      t.datetime :current_period_start, null: false
      t.datetime :current_period_end, null: false

      t.timestamps
    end

    add_index :subscriptions, :stripe_customer_id, unique: true
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
