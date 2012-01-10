class AddNewProjectIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :new_project_id, :integer
  end

  def self.down
    remove_column :users, :new_project_id
  end
end
