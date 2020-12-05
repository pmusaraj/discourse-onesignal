# frozen_string_literal: true

class CreateOnesignalSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :onesignal_subscriptions do |t|
      t.integer :user_id, null: false
      t.string :device_token, null: false
      t.string :application_name, null: false
      t.string :platform, null: false
      t.timestamps
    end

    add_index :onesignal_subscriptions, [:device_token], unique: true

  end
end
