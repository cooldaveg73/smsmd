Factory.define :doctor do |f|
  f.sequence(:first_name)	{ |n| "Khanh-#{n}" }
  f.sequence(:last_name)	{ |n| "Le-#{n}" }
  f.mobile			{ random_mobile }
  f.status			"available"
  f.sequence(:last_paged)	{ |n| (n+10).minutes.ago.utc.to_datetime }
  f.association			:hospital		
  f.association			:project
end
