include MessagesHelper

class ReplaceNilPatientsInCases < ActiveRecord::Migration
  def self.up
    Case.where("patient_id IS NULL").each do |kase|
      req_msg = kase.opening_message.msg
      message_words = req_msg.strip.split(/\s+/)
      if check_req_format(message_words)
        kase.patient = create_patient_for_vhd(Vhd.first, message_words)
      end
      kase.save
    end
  end

  def self.down
  end
end
