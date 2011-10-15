class CreatePagingSchemes < ActiveRecord::Migration
  def self.up
    create_table :paging_schemes do |t|
      t.integer :project_id
      t.integer :priority
      t.integer :doctor_id
      t.boolean :random_doctor, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :paging_schemes
  end
end
