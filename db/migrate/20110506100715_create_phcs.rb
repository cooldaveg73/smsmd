class CreatePhcs < ActiveRecord::Migration
  def self.up
    create_table :phcs do |t|
      t.string :name, :limit => 255
      t.string :contact_name, :limit => 255
      t.string :contact_number, :limit => 20

      t.timestamps
    end
  end

  def self.down
    drop_table :phcs
  end
end
