# == Schema Information
#
# Table name: codes
#
#  id           :integer(4)      not null, primary key
#  abbreviation :string(255)
#  expansion    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Code < ActiveRecord::Base
  validates :abbreviation,	:length => { :maximum => 255 }
  validates :expansion,		:length => { :maximum => 255 }

  def self.expand(msg, filter_fin=false)
    dict = {}
    Code.all.each { |item| dict[item.abbreviation] = item.expansion }
    message_words = msg.strip.split(/\s+/)
    if filter_fin
      first_word = message_words.delete_at(0)
      first_word.gsub!(/\W|fin/i, "")
      message_words = [first_word] + message_words unless first_word.blank?
    end
    message_words[0...message_words.size].map do |word|
      punctuation_saved = digits_saved = ""
      while word.length > 0
        if word.last.match(/\W/)
	  punctuation_saved = word.last + punctuation_saved
	  word = word[0...(word.length - 1)] 
	elsif word.first.match(/\d/)
	  digits_saved += word.first
	  word = word[1...word.length] 
	else
	  break
	end
      end
      digits_saved += " " if digits_saved.length > 0
      word = dict[word.upcase].nil? ? word : dict[word.upcase]
      word = digits_saved + word + punctuation_saved
    end.join(" ")
  end

end
