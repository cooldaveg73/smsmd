class RenameTypeInDemoers < ActiveRecord::Migration
  def self.up
    rename_column :demoers, :type, :demoer_type
  end

  def self.down
    rename_column :demoers, :demoer_type, :type
  end
end
