# this file stores helper methods for use across different factory files

$lorem_text = "lorem ipsum dolor sit amet consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum"

def random_mobile
  return rand(10 ** 10).to_s.rjust( 10 , (1 + rand(9)).to_s )
end

# random text generator for use in generating unique message content
def random_lorem(min_words = 6, max_words = 15)
  lorem_words = $lorem_text.split(/\s+/)
  num_words = lorem_words.count
  low_index = rand(num_words - min_words) 
  range = min_words + rand(max_words - min_words)
  high_index = low_index + range - 1
  high_index = num_words - 1 if high_index >= num_words
  lorem_words[low_index..high_index].sort_by{ rand }.join(" ")
end
