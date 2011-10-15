class AddPhcIdToVhds < ActiveRecord::Migration
  def self.up
    add_column :vhds, :phc_id, :integer
  end

  def self.down
    remove_column :vhds, :phc_id
  end
end
