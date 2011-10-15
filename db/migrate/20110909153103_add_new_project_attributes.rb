class AddNewProjectAttributes < ActiveRecord::Migration
  def self.up
    add_column :projects, :has_reqs, :boolean, :default => false
    add_column :projects, :has_hlps, :boolean, :default => false
    add_column :projects, :include_doctor_name, :boolean, :default => true
    add_column :projects, :include_doctor_mobile, :boolean, :default => true

    add_column :projects, :mobile, :string, :limit => 24,
      :default => DEFAULT_SYSTEM_NUM
    add_column :projects, :unregistered_msg, :string, :limit => 1024,
      :default => DEFAULT_UNREGISTERED_MSG
    add_column :projects, :close_msg, :string, :limit => 1024,
      :default => DEFAULT_CLOSE_MSG
    add_column :projects, :req_format_msg, :string, :limit => 1024,
      :default => DEFAULT_REQ_FORMAT_MSG

    # the number of hours offset from UTC
    add_column :projects, :time_zone, :decimal, :precision => 3, :scale => 1
  end

  def self.down
  end
end
