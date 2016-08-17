# This file is part of Mconf-Web, a web applition that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf::Highlighter
  def self.highlight_word(text, word)
    return "" if text.blank?
    return text if word.blank?

    begin_mark = "<mark>"
    end_mark = "</mark>"
    text = text.clone
    indexes = []
    tt = ActiveSupport::Inflector.transliterate(text).downcase
    tw = ActiveSupport::Inflector.transliterate(word).downcase
    displacement = 0

    while tt && i = tt.index(/#{tw}[^>]|#{tw}$/)
      if i
        i += displacement
        indexes << i
        tt = tt[i + 1 , tt.size - tw.size + 1]
        displacement += i + 1
      end
    end

    displacement = 0
    indexes.each do |i|
      text.insert(i + displacement, begin_mark)
      displacement += begin_mark.size
      text.insert((i + tw.size + displacement), end_mark)
      displacement += end_mark.size
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
      highlight_word(text, words)
    end
  end
end
