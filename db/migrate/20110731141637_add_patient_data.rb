class AddPatientData < ActiveRecord::Migration
  def self.up
    add_column :patients, :registered, :boolean
    add_column :patients, :project_id, :integer
    add_column :patients, :department_name, :string
    add_column :patients, :doctor_id, :integer
  end

  def self.down
    remove_column :patients, :registered
    remove_column :patients, :project_id
    remove_column :patients, :department_name
    remove_column :patients, :doctor_id
  end
end
