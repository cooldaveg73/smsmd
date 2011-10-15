class AddTagToCases < ActiveRecord::Migration
  def self.up
    add_column :cases, :tag, :integer
    Project.all.each do |p|
      tag = 1
      p.cases.each do |c|
        c.update_attributes(:tag => tag)
	tag += 1
      end
    end
  end

  def self.down
    remove_column :cases, :tag
  end
end
