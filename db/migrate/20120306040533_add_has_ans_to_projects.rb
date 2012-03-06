class AddHasAnsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :has_ans, :boolean
  end

  def self.down
    remove_column :projects, :has_ans
  end
end
