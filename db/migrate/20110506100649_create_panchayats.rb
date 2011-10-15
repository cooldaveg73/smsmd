class CreatePanchayats < ActiveRecord::Migration
  def self.up
    create_table :panchayats do |t|
      t.string :name, :limit => 255
      t.integer :phc_id
      t.integer :block_id

      t.timestamps
    end
  end

  def self.down
    drop_table :panchayats
  end
end
