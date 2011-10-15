Factory.define :vhd do |f|
  f.sequence(:first_name)	{ |n| "PCM-#{n}" }
  f.sequence(:last_name)	{ |n| "Meghwal-#{n}" }
  f.mobile			{ random_mobile }
  f.status			"vacant"
  f.project			{ |u| u.association(:project) }
end
