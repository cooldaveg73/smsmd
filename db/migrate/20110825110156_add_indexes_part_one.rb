class AddIndexesPartOne < ActiveRecord::Migration
  def self.up
    add_index :cases, :project_id
    add_index :cases, :vhd_id
    add_index :cases, :doctor_id
    add_index :doctors, :project_id
    add_index :messages, :from_vhd_id
    add_index :messages, :from_doctor_id
    add_index :messages, :to_doctor_id
    add_index :messages, :to_vhd_id
    add_index :messages, :case_id
    add_index :messages, :project_id
    add_index :vhds, :project_id
  end

  def self.down
    remove_index :cases, :project_id
    remove_index :cases, :vhd_id
    remove_index :cases, :doctor_id
    remove_index :doctors, :project_id
    remove_index :messages, :from_vhd_id
    remove_index :messages, :from_doctor_id
    remove_index :messages, :to_doctor_id
    remove_index :messages, :to_vhd_id
    remove_index :messages, :case_id
    remove_index :messages, :project_id
    remove_index :vhds, :project_id
  end
end
