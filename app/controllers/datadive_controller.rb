class DatadiveController < ApplicationController

  def ignored_words
    %w(1 2 3 4 5 6 7 8 9 10 acc and to me days at for bd tds od qid stat sos ac pc)
  end

  def overview
    @project = get_project_and_set_subtitle
    @title = "DataDive (SF 2011)"
    monthly_freq = get_drug_freq(1.month.ago)
    yearly_freq = get_drug_freq(1.year.ago)
    freq_trend = {}
    monthly_freq.each_pair do |word, f_m|
      f_y = yearly_freq[word]
      freq_trend[word] = f_m - f_y
    end
    @words_monthly = word_list_from_word_freq(monthly_freq)
    @words_yearly = word_list_from_word_freq(yearly_freq)
    @words_trending = word_list_from_word_freq(freq_trend)
  end

  def word_list_from_word_freq(word_freq, max=50)
    ignored = ignored_words
    word_list = []
    word_freq.each_pair do |word, freq|
      word_list << [freq, word] unless ignored.include? word
    end
    word_list.sort_by{|x| -x[0].abs}[0..max]
  end

  def get_drug_freq(start_date, end_date = Time.now)
    leading_words = %w(tab cap oint tsf liq syp)
    messages = Message.where(:from_person_type => 'Doctor').where('time_received_or_sent between :start_date and :end_date', {:start_date => start_date, :end_date => end_date}).where('case_id is not null').all
    message_count = messages.length
    word_freq = {}
    word_freq.default = 0
    messages.each do |m|
      #Filter out everything except final recommendations
      unless m.msg =~ /fin/i
        message_count -= 1
        next
      end
      suspected_drug = false
      m.msg.split.each do |word|
        word_freq[word] = word_freq[word] + 1 if suspected_drug
        suspected_drug = false
        suspected_drug = true if leading_words.include? word
      end
    end

    word_freq.each_key do |word|
      word_freq[word] = Float(word_freq[word] * 100) / message_count
    end
    word_freq
  end

    

  def get_word_freq (start_date, end_date = Time.now)
    messages = Message.where(:from_person_type => 'Doctor').where('time_received_or_sent between :start_date and :end_date', {:start_date => start_date, :end_date => end_date})
    message_count = messages.length
    word_freq = {}
    word_freq.default = 0
    messages.each do |m|
      m.msg.split.each do |word|
        word_freq[word] = word_freq[word] + 1
      end
    end

    word_freq.each_key do |word|
      word_freq[word] = Float(word_freq[word] * 100) / message_count
    end
    word_freq
  end

end
