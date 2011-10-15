class CreateNotifySchemes < ActiveRecord::Migration
  def self.up
    create_table :notify_schemes do |t|
      t.integer :pm_id
      t.integer :project_id
      t.string :type, :limit => 24

      t.timestamps
    end
  end

  def self.down
    drop_table :notify_schemes
  end
end
