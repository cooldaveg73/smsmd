class AlterIndexes < ActiveRecord::Migration
  def self.up
    add_index :messages, :from_person_type
    add_index :messages, :from_person_id
    add_index :messages, :to_person_type
    add_index :messages, :to_person_id
  end

  def self.down
    remove_index :messages, :from_person_type
    remove_index :messages, :from_person_id
    remove_index :messages, :to_person_type
    remove_index :messages, :to_person_id
  end
end
