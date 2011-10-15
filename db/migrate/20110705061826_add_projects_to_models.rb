# Custom migration by David Groff

class AddProjectsToModels < ActiveRecord::Migration
  def self.up
    add_column :vhds, :project_id, :integer
    add_column :doctors, :project_id, :integer
    add_column :apms, :project_id, :integer
  end

  def self.down
    remove_column :vhds, :project_id
    remove_column :doctors, :project_id
    remove_column :apms, :project_id
  end
end

