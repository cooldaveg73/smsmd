Factory.define :promoter do |f|
  f.sequence(:name)		{ |n| "Josh-#{n} Nesbitt-#{n}" }
  f.sequence(:organization)	{ |n| "One-#{n}" }
  f.sequence(:industry)		{ |n| "Bullshit-10#{n}" }
  f.country			"India"
  f.website			{ |u| "www.#{u.organization}.org" }
  f.sequence(:username)		{ |n| "josh#{n}" }
  f.email			{ |u| "#{u.username}@#{u.organization}.org" }
end
