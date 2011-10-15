class CreatePms < ActiveRecord::Migration
  def self.up
    create_table :pms do |t|
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
      t.string :mobile, :limit => 20
      t.boolean :active
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pms
  end
end
