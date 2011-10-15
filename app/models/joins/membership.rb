# == Schema Information
#
# Table name: memberships
#
#  id          :integer(4)      not null, primary key
#  person_type :string(255)
#  person_id   :integer(4)
#  project_id  :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Membership < ActiveRecord::Base
  belongs_to :project
  belongs_to :person,	:polymorphic => true

  validates :person_type,	:inclusion => { :in => ["Pm", "User"] }
  validates :project,		:presence => true
end
