Factory.define :patient do |f|
  meta_age_arr = ["Adult", "Child", "Infant", "Pregnant Woman", "Elder"]
  f.first_name do 
    ("zachary"+random_lorem(1, 1)).split("").shuffle.join[0..15].humanize
  end
  f.last_name do 
    ("datko"+random_lorem(1, 1)).split("").shuffle.join[0..15].humanize
  end
  f.sequence(:meta_age)		{ |n| n.even? ? meta_age_arr[(n/2) % 5] : nil }
  f.sequence(:age)		{ |n| n.odd? ? rand(60) : nil }
  f.mobile			{ random_mobile }
end
