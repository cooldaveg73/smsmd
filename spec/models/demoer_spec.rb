# == Schema Information
#
# Table name: demoers
#
#  id          :integer(4)      not null, primary key
#  mobile      :string(255)
#  demoer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  acc         :boolean(1)      default(FALSE)
#

require 'spec_helper'

describe Demoer do
  pending "add some examples to (or delete) #{__FILE__}"
end

