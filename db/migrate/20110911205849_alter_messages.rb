class AlterMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :from_person_id, :integer
    add_column :messages, :to_person_id, :integer
    Message.all.each do |message|
      if !message.from_doctor.nil?
        message.from_person = message.from_doctor
      elsif !message.from_pm.nil?
        message.from_person = message.from_pm
      elsif !message.from_vhd.nil?
        message.from_person = message.from_vhd
      else
        message.from_person_type = nil
      end
      if !message.to_doctor.nil?
        message.to_person = message.to_doctor
      elsif !message.to_pm.nil?
        message.to_person = message.to_pm
      elsif !message.to_vhd.nil?
        message.to_person = message.to_vhd
      else
        message.to_person_type = nil
      end
      message.save
    end
    remove_column :messages, :from_doctor_id
    remove_column :messages, :from_pm_id
    remove_column :messages, :from_vhd_id
    remove_column :messages, :to_doctor_id
    remove_column :messages, :to_pm_id
    remove_column :messages, :to_vhd_id
  end

  def self.down
    add_column :messages, :to_vhd_id, :integer
    add_column :messages, :to_pm_id, :integer
    add_column :messages, :to_doctor_id, :integer
    add_column :messages, :from_vhd_id, :integer
    add_column :messages, :from_pm_id, :integer
    add_column :messages, :from_doctor_id, :integer
    remove_column :messages, :to_person_id
    remove_column :messages, :from_person_id
  end
end
