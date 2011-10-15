class CreateDoctors < ActiveRecord::Migration
  def self.up
    create_table :doctors do |t|
      t.string :first_name, :limit => 20
      t.string :last_name, :limit => 20
      t.string :mobile, :limit => 20
      t.string :status, :limit => 10
      t.datetime :last_paged
      t.string :specialty, :limit => 20
      t.integer :hospital_id
      t.boolean :active
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :doctors
  end
end
