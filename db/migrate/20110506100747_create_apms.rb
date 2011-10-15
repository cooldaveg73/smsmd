class CreateApms < ActiveRecord::Migration
  def self.up
    create_table :apms do |t|
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
      t.string :mobile, :limit => 20

      t.timestamps
    end
  end

  def self.down
    drop_table :apms
  end
end
