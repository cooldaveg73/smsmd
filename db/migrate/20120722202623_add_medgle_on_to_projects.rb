class AddMedgleOnToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :medgle_on, :boolean, :default => false
    Project.where("name = ?", "Udaipur").first.medgle_on = true
  end

  def self.down
    remove_column :projects, :medgle_on
  end
end
