class AddKeyToPromoters < ActiveRecord::Migration
  def self.up
    add_column :promoters, :key, :string, :limit => 1024
  end

  def self.down
    remove_column :promoters, :key
  end
end
