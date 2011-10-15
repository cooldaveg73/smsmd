class AddPatientVhds < ActiveRecord::Migration
  def self.up
    # add the new fields necessary for vhds
    add_column :vhds, :is_patient, :boolean, :default => false
    add_column :vhds, :doctor_id, :integer
    add_column :vhds, :department, :string, :limit => 24
    # add all the new vhds
    project = Project.find_by_name("Mission Hospital")
    project.patients.each do |p|
      p.first_name = "PATIENT" if p.first_name.blank?
      p.last_name = "PATIENT" if p.last_name.blank?
      vhd = Vhd.create(:first_name => p.first_name, 
        :last_name => p.last_name, 
	:mobile => p.mobile, 
	:status => "vacant", 
	:project => project, 
	:is_patient => true, 
	:doctor_id => p.doctor_id, 
	:department => p.department_name)
      p.cases.each do |kase|
        kase.update_attributes(:vhd => vhd, :patient => nil)
      end
      p.messages_as_to_patient.each do |m|
        m.update_attributes(:to_vhd => vhd, :to_patient => nil)
      end
      p.messages_as_from_patient.each do |m|
        m.update_attributes(:from_vhd => vhd, :from_patient => nil)
      end
      p.reload.destroy
    end
    # remove unused fields for patients and messages
    remove_column :patients, :project_id
    remove_column :patients, :department_name
    remove_column :patients, :doctor_id
    remove_column :messages, :from_patient_id
    remove_column :messages, :to_patient_id
  end

  def self.down
    add_column :messages, :to_patient_id
    add_column :messages, :from_patient_id
    add_column :patients, :doctor_id, :integer
    add_column :patients, :department_name, :string, :limit => 24
    add_column :patients, :project_id, :integer
    remove_column :vhds, :department
    remove_column :vhds, :doctor_id
    remove_column :vhds, :is_patient
  end
end
