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
#  email           :string(256)
#  new_project_id  :integer(4)
#

require 'spec_helper'

describe User do


end
