class CreateShifts < ActiveRecord::Migration
  def self.up
    create_table :shifts do |t|
      t.integer :start_hour
      t.integer :start_minute
      t.integer :start_second
      t.integer :end_hour
      t.integer :end_minute
      t.integer :end_second
      t.integer :doctor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :shifts
  end
end
