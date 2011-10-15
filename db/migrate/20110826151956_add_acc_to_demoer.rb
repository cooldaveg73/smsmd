class AddAccToDemoer < ActiveRecord::Migration
  def self.up
    add_column :demoers, :acc, :boolean, :default => false
  end

  def self.down
    remove_column :demoers, :acc
  end
end
