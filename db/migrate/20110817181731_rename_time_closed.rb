class RenameTimeClosed < ActiveRecord::Migration
  def self.up
    rename_column :cases, :time_closed, :time_closed_or_resolved
  end

  def self.down
    rename_column :cases, :time_closed_or_resolved, :time_closed
  end
end
