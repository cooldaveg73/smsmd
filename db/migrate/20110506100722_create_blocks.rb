class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.string :name, :limit => 255
      t.integer :apm_id

      t.timestamps
    end
  end

  def self.down
    drop_table :blocks
  end
end
