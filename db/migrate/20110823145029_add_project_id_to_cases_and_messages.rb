class AddProjectIdToCasesAndMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :project_id, :integer
    add_column :cases, :project_id, :integer
  end

  def self.down
    remove_column :messages, :project_id
    remove_column :cases, :project_id
  end
end
