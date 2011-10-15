# == Schema Information
#
# Table name: paging_records
#
#  id               :integer(4)      not null, primary key
#  case_id          :integer(4)
#  paging_scheme_id :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

class PagingRecord < ActiveRecord::Base
  belongs_to :case
  belongs_to :paging_scheme
end
