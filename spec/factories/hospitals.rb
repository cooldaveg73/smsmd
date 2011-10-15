Factory.define :hospital do |f|
  f.sequence(:name)	{ |n| "Hospital-#{n}" }
end
