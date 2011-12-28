module NewProjectHelper

  def generate_temp_key(min_length=6, variation=5)
    random_chars = ('A'..'Z').to_a + ('a'..'z').to_a + (1..9).to_a.map { |i| i.to_s }
    temp_key = ""
    (rand(variation) + min_length).times { |i| temp_key << random_chars[rand(random_chars.count)] }
  end
end
