class CreateDemoers < ActiveRecord::Migration
  def self.up
    create_table :demoers do |t|
      t.string :mobile
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :demoers
  end
end
