class AddPatientBuyerInfoToVhds < ActiveRecord::Migration
  def self.up
    add_column :vhds, :is_patient_buyer, :boolean
    add_column :vhds, :buyer_count, :integer
  end

  def self.down
    remove_column :vhds, :buyer_count
    remove_column :vhds, :is_patient_buyer
  end
end
