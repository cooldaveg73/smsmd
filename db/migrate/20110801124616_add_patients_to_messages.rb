class AddPatientsToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :to_patient_id, :integer
    add_column :messages, :from_patient_id, :integer
  end

  def self.down
    remove_column :messages, :to_patient_id
    remove_column :messages, :from_patient_id
  end
end
