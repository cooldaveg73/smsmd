Factory.define :project do |f|
  f.sequence(:name)	{ |n| "Project-#{n}" }
  f.time_zone		5.5
end
