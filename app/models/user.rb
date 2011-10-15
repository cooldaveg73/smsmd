# == Schema Information
#
# Table name: users
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  hashed_password :string(255)
#  salt            :string(255)
#  is_admin        :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password_confirmation
  attr_reader :password

  has_many :memberships,	:as => :person,
                                :dependent => :destroy
  has_many :projects,		:through => :memberships

  has_one :pm,			:dependent => :nullify
  has_one :doctor,		:dependent => :nullify
  has_one :vhd,			:dependent => :nullify

  validates :name,		:presence => true,
				:uniqueness => true
  validates :password, 		:confirmation => true
  validate :password_must_be_present



  def User.encrypt_password(password, salt)
    Digest::SHA256.hexdigest(password + "wibble" + salt)
  end

  def User.authenticate(name, password, project)
    if user = find_by_name(name)
      if user.hashed_password == encrypt_password(password, user.salt)
        if project.nil?
	  return user
	else
	  return user.authenticate_project(project)
	end
      end
    end
  end

  def password=(password)
    @password = password
    
    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  private

    def authenticate_project(project)
      return self if self.projects.include?(project)
    end

    def password_must_be_present
      unless hashed_password.present?
        errors.add(:password, "Missing password")
      end
    end

    def generate_salt
      self.salt = Digest::SHA256.hexdigest(self.object_id.to_s + rand.to_s + Time.now.strftime("%s"))
    end
end
