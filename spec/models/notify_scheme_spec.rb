# == Schema Information
#
# Table name: notify_schemes
#
#  id         :integer(4)      not null, primary key
#  pm_id      :integer(4)
#  project_id :integer(4)
#  alert_type :string(24)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe NotifyScheme do
  pending "add some examples to (or delete) #{__FILE__}"
end

