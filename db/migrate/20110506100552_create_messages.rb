class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.boolean :incoming
      t.string :msg, :limit => 1024

      t.string :from_number, :limit => 20
      t.string :from_person_type, :limit => 8
      t.integer :from_vhd_id
      t.integer :from_pm_id
      t.integer :from_doctor_id
      
      t.string :to_number, :limit => 20
      t.string :to_person_type, :limit => 8
      t.integer :to_doctor_id
      t.integer :to_vhd_id
      t.integer :to_pm_id
      
      t.integer :case_id
      t.datetime :time_received_or_sent
      t.string :external_id, :limit => 255
      t.string :gateway_status, :limit => 255
      t.datetime :time_delivered

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
