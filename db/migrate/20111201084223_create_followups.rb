class CreateFollowups < ActiveRecord::Migration
  def self.up
    create_table :followups do |t|
      t.integer :case_id
      t.string :patient_gender, :limit => 10
      t.integer :days_sick
      t.boolean :still_sick
      t.boolean :within_24_hours
      t.boolean :followed_advice
      t.string :followed_advice_comments, :limit => 20
      t.boolean :would_use_again
      t.string :patient_work, :limit => 20
      t.integer :patient_family_size
      t.integer :patient_family_income
      t.string :talked_with, :limit => 20
      t.boolean :case_is_real
      t.string :case_is_real_comments, :limit => 40
      t.string :general_comments
      t.text :symptoms
      t.text :patient_did
      t.text :doctor_recommended

      t.timestamps
    end
  end

  def self.down
    drop_table :followups
  end
end
