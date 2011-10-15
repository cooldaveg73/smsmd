Factory.define :doctor_demoer, :class => "Demoer" do |f|
  f.mobile		{ random_mobile }
  f.demoer_type 	"doctor"
end

Factory.define :receiver_demoer, :class => "Demoer" do |f|
  f.mobile		{ random_mobile }
  f.demoer_type		"receiver"
end

Factory.define :vhd_demoer, :class => "Demoer" do |f|
  f.mobile		{ random_mobile }
  f.demoer_type		"vhd"
end
