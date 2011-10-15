# VHDS List
# all are vacant and on udaipur project
# we have to recove info for every case and every message
#
# id mobile	first	last	notes
# 1  9636740365	P.C.M.	   Meghwal	   Airtel, Age 24, MA Economics
# 2  9529361881	Sheela     Ramesh	   Added to send SMS on behalf of female calling VHDs
# 4  9783758178	Durgesh	   Menaria	   Vodafone, Age 30, MA L L B
# 5  9001088808	Prahlad	   Pushkarana	
# 6  9166583569	Dharmendra Singh
# 7  9928723641	Laxmi	   Rajput	   Airtel, Age 28, 12th Grade
# 8  9001790133	Bhagirath  Vyas	           Airtel, Age 40, M.A. B. Ped.
# 9  9649501965	Mobahhat   Rathore	   Vodafone, Age 22, 10th Grade
# 10 9660872009	Durga	   Rathore	   Airtel, Age 21, B. Comm.
# 11 9784922387	Devilal	   Meena	   Airtel, 22, Xth
# 13 9829788276	Dinesh	   Menaria	   Airtel\r\n24 years old\r\nEducation: M.A., B. Ed., M. Ed.
# 14 9929849087	Govind	   Mehta	   Airtel\r\n25 years old\r\nMA. B. Ed
# 15 9950222911	Manaram	   Patel	
# 16 9829191988	Jagdish	   Jat    	   Airtel\r\n29 years old\r\nEducation: B.A.
# 17 9928496752	Prakash	   Jat	           Airtel\r\n22 years old\r\nEducation: 12th standard
# 18 9928640619	Mukesh	   Jat	   	   Airtel\r\n21 years old\r\nEducation: 1st year B.A.
# 19 9829585056	Gopal	   Menaria	   Airtel\r\n27 years old\r\nEducation: MCA
# 20 9636585270	Leela	   Megwal	
# 21 9829597093	Yashodha   Punia
#

class RecoverLostVhds < ActiveRecord::Migration
  def self.up
    ids = [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 21]
    mobiles = ["9636740365", "9529361881", "9783758178", "9001088808", "9166583569", "9928723641", "9001790133", "9649501965", "9660872009", "9784922387", "9829788276", "9929849087", "9950222911", "9829191988", "9928496752", "9928640619", "9829585056", "9829597093"]
    first_names = [ "P.C.M.", "Sheela", "Durgesh", "Prahlad", "Dharmendra", "Laxmi", "Bhagirath", "Mobahhat", "Durga", "Devilal", "Dinesh", "Govind", "Manaram", "Jagdish", "Prakash", "Mukesh", "Gopal", "Leela", "Yashodha"]
    last_names = ["Meghwal", "Ramesh", "Menaria", "Pushkarana", "Singh", "Rajput", "Vyas", "Rathore", "Rathore", "Meena", "Menaria", "Mehta", "Patel", "Jat", "Jat", "Jat", "Menaria", "Megwal", "Punia" ] 
    notes = [ "Airtel, Age 24, MA Economics", "Added to send SMS on behalf of female calling VHDs", "Vodafone, Age 30, MA L L B", "", "", "Airtel, Age 28, 12th Grade", "Airtel, Age 40, M.A. B. Ped.", "Vodafone, Age 22, 10th Grade", "Airtel, Age 21, B. Comm.", "Airtel, 22, Xth", "Airtel\r\n24 years old\r\nEducation: M.A., B. Ed., M. Ed.", "Airtel\r\n25 years old\r\nMA. B. Ed", "", "Airtel\r\n29 years old\r\nEducation: B.A.", "Airtel\r\n22 years old\r\nEducation: 12th standard", "Airtel\r\n21 years old\r\nEducation: 1st year B.A.", "Airtel\r\n27 years old\r\nEducation: MCA", "", "" ]
    (0...mobiles.size).each do |i|
      vhd = Vhd.find_by_mobile(mobiles[i])
      if vhd.nil?
        vhd = Vhd.create( :mobile => mobiles[i], :first_name => first_names[i],
	                  :last_name => last_names[i], :notes => notes[i],
			  :project => Project.first, :status => "vacant" )
      end
      old_id = ids[i]
      Message.where("to_vhd_id = ?", old_id).each do |message|
        message.update_attributes( :to_vhd_id => vhd.id )
      end
      Message.where("from_vhd_id = ?", old_id).each do |message|
        message.update_attributes( :from_vhd_id => vhd.id )
      end
      Case.where("vhd_id = ?", old_id).each do |kase|
        kase.update_attributes( :vhd_id => vhd.id)
      end
    end
  end

  def self.down
  end
end
