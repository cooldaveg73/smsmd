class ActiveRecord::Base
  $rescue_message = "rescued #{self.class} and doing nothing: see config/initializers/active_record_patch.rb"

  def self.create(params)
    if Rails.env.production?
      begin
	self.create!(params)
      rescue
	puts $rescue_message
	return false
	# TODO: Figure out what to do here
      end
    else
      self.create!(params)
    end
  end

  def save
    if Rails.env.production?
      begin
	self.save!
      rescue
	puts $rescue_message    
	return false
	# TODO: Figure out what to do here
      end
    else
      self.save!
    end
  end

end
