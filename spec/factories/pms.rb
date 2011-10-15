Factory.define :pm do |f|
  f.sequence(:first_name)	{ |n| "Sheela#{n}" }
  f.sequence(:last_name)	{ |n| "Rameshware#{n}" }
  f.mobile			{ random_mobile }
  f.active			true
end
