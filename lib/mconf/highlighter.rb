# This file is part of Mconf-Web, a web applition that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.
include ActiveSupport::Inflector

module Mconf::Highlighter
  def self.highlight_word(text, word) # options = {}
    #text = sanitize(text) if options.fetch(:sanitize, true)
    return "" if text.blank?
    return text if word.blank?
    text = text.clone #clona texto pra nao usar a mesma variável
    indexes = [] 
    tt = transliterate(text).downcase
    tw = transliterate(word).downcase
    displacement = 0
    i = 0

    while tt && i = tt.index(/#{tw}[^>]|#{tw}$/)
      if i
        i += displacement
        indexes << i
        tt = tt[i + 1 , tt.size - tw.size + 1]

        displacement += i + 1
      end
    end
    
    d = 0
    indexes.each do |i| 
      text.insert(i + d, '<mark>')
      d += 6
      text.insert((i + tw.size + d), '</mark>' )
      d += 7
    end
    text
  end

  def self.highlight(text, words)
    if words.kind_of?(Array)
      words.each do |word|
        text = highlight_word(text, word)
      end
      text
    else
      highlight_word(text,words) #as the function might receive a string or an array, this test is necessary.
    end
  end
end

