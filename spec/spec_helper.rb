# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
    
  DELETE_RESTRICTED = ActiveRecord::DeleteRestrictionError
  RECORD_NOT_FOUND = ActiveRecord::RecordNotFound

  def page_doctor_and_return_case(doctor, options={} )
    new_case = Factory(:newly_opened_case, options)
    Factory(:page_message, :to_person => doctor, :case => new_case,
	    :time_sent => new_case.time_opened )
    return new_case
  end

  def random_datetime_today
    number_of_seconds_to_randomize = 22*60*60 # uses ten hours
    beginning_of_day = DateTime.now.new_offset(+5.5/24).beginning_of_day.to_i
    random_time = beginning_of_day + rand(number_of_seconds_to_randomize)
    return Time.at(random_time).to_datetime.new_offset(+5.5/24)
  end

end
