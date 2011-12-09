Factory.define :user do |f|
  f.sequence(:name)	{ |n| "admin-#{n}" }
  f.password		"password"
  f.is_admin		true
end
