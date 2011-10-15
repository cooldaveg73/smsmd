# == Schema Information
#
# Table name: paging_schemes
#
#  id            :integer(4)      not null, primary key
#  project_id    :integer(4)
#  priority      :integer(4)
#  doctor_id     :integer(4)
#  random_doctor :boolean(1)      default(TRUE)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe PagingScheme do
  pending "add some examples to (or delete) #{__FILE__}"
end
