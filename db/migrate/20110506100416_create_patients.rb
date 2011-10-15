class CreatePatients < ActiveRecord::Migration
  def self.up
    create_table :patients do |t|
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
      t.integer :age
      t.string :meta_age, :limit => 255
      t.string :mobile, :limit => 20

      t.timestamps
    end
  end

  def self.down
    drop_table :patients
  end
end
