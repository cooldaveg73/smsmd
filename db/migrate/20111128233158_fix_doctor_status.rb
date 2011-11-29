class FixDoctorStatus < ActiveRecord::Migration
  def self.up
    saved_stati = {}
    Doctor.all.each { |d| saved_stati[d] = d.status }
    remove_column :doctors, :status
    add_column :doctors, :status, :string, :limit => 24
    saved_stati.each  do |doctor, status|
      doctor.reload
      if status.match(/deactivat/)
        doctor.status = "deactivated"
      else
        doctor.status = status
      end
      doctor.save
    end
  end

  def self.down
  end
end
