class RenameTypeColumnInNotifySchemes < ActiveRecord::Migration
  def self.up
    rename_column :notify_schemes, :type, :alert_type
  end

  def self.down
    rename_column :notify_schemes, :alert_type, :type
  end
end
