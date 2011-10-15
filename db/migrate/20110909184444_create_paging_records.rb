class CreatePagingRecords < ActiveRecord::Migration
  def self.up
    create_table :paging_records do |t|
      t.integer :case_id
      t.integer :paging_scheme_id

      t.timestamps
    end
  end

  def self.down
    drop_table :paging_records
  end
end
