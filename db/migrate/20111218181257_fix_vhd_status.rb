class FixVhdStatus < ActiveRecord::Migration
  def self.up
    saved_stati = {}
    Vhd.all.each { |d| saved_stati[d] = d.status }
    remove_column :vhds, :status
    add_column :vhds, :status, :string, :limit => 24
    saved_stati.each  do |vhd, status|
      vhd.reload
      if status.match(/deactivat/)
        vhd.status = "deactivated"
      else
        vhd.status = status
      end
      vhd.save
    end
  end

  def self.down
  end
end
