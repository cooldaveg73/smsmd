class AlterMessagesPartTwo < ActiveRecord::Migration
  def self.up
    Message.all.each do |m|
      if m.to_person_id.nil?
        Message.to_person = find_person(m.to_number)
      end

      if m.from_person_id.nil?
        Message.from_person = find_person(m.from_number)
      end
      Message.save
    end
  end

  def self.down
  end

  def find_person(mobile)
    return vhd if (vhd = Vhd.find_by_mobile(mobile))
    return doctor if (doctor = Doctor.find_by_mobile(mobile))
    return pm if (pm = Pm.find_by_mobile(mobile))
    return nil
  end
end
