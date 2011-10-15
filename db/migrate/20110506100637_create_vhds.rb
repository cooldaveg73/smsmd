class CreateVhds < ActiveRecord::Migration
  def self.up
    create_table :vhds do |t|
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
      t.string :mobile, :limit => 20
      t.string :status, :limit => 10
      t.string :notes, :limit => 1024
      t.integer :village_id
      t.integer :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :vhds
  end
end
