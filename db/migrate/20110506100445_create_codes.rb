class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.string :abbreviation, :limit => 255
      t.string :expansion, :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :codes
  end
end
