class CreatePromoters < ActiveRecord::Migration
  def self.up
    create_table :promoters do |t|
      t.string :name, :limit => 128
      t.string :organization, :limit => 32
      t.string :industry, :limit => 32
      t.string :country, :limit => 32
      t.string :website, :limit => 1024
      t.string :email, :limit => 128
      t.string :username, :limit => 24

      t.timestamps
    end
  end

  def self.down
    drop_table :promoters
  end
end
