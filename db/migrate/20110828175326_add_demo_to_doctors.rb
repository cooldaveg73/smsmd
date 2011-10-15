class AddDemoToDoctors < ActiveRecord::Migration
  def self.up
    add_column :doctors, :points, :integer, :default => 0
    add_column :doctors, :points_timestamp, :datetime
  end

  def self.down
    remove_column :doctors, :points_timestamp
    remove_column :doctors, :points
  end
end
