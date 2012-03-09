class AddPatientBuyerInfoToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :has_patient_buyers, :boolean
    add_column :projects, :has_doctor_game, :boolean
    add_column :projects, :hlp_format_msg, :string, :limit => 1024, :default => DEFAULT_HLP_FORMAT_MSG
  end

  def self.down
    remove_column :projects, :hlp_format_msg
    remove_column :projects, :has_doctor_game
    remove_column :projects, :has_patient_buyers
  end
end
