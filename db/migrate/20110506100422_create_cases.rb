class CreateCases < ActiveRecord::Migration
  def self.up
    create_table :cases do |t|
      t.string :status, :limit => 10
      t.boolean :followed_up
      t.boolean :fake
      t.boolean :success
      t.boolean :alerted
      t.integer :doctor_id
      t.integer :vhd_id
      t.integer :patient_id
      t.datetime :time_opened
      t.datetime :time_accepted

      # time_closed is repurposed as a time_closed_or_resolved field
      t.datetime :time_closed
      t.datetime :last_message_time

      t.timestamps
    end
  end

  def self.down
    drop_table :cases
  end
end
