Factory.define :shift do |f|
  f.start_hour		0
  f.start_minute	0
  f.start_second	0
  f.end_hour		23
  f.end_minute		59
  f.end_second		59
  f.association		:doctor
end
