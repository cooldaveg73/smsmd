class AlterMessagesPartTwo < ActiveRecord::Migration

  def self.find_person(mobile)
    doctor = Doctor.find_by_mobile(mobile)
    return doctor unless doctor.nil?
    vhd = Vhd.find_by_mobile(mobile)
    return vhd unless vhd.nil?
    pm = Pm.find_by_mobile(mobile)
    return pm unless pm.nil?
    return nil
  end

  def self.up
    Message.all.each do |m|
      if m.to_person_id.nil?
        m.to_person = find_person(m.to_number)
      end

      if m.from_person_id.nil?
        m.from_person = find_person(m.from_number)
      end
      m.save
    end
  end

  def self.down
  end

end
