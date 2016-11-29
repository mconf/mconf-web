# This file is part of Mconf-Web, a web applition that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf::Highlighter
  def self.highlight_word(text, word)
    return "" if text.blank?
    return text if word.blank?

    indexes = get_highlight_indexes(text, word)
    set_highlight_on_indexes(text, indexes)
  end

  def self.highlight(text, words)
    if words.kind_of?(Array)
      words = words.uniq
      indexes = []
      words.each do |word|
        indexes.concat get_highlight_indexes(text, word)
      end
      indexes = crop_indexes(indexes)
      set_highlight_on_indexes(text, indexes.sort{ |a,b| a[0] <=> b[0] })
    else
      highlight_word(text, words)
    end
  end

  private


  def self.crop_indexes(indexes)
    idx = indexes.clone
    idx = idx.sort_by{ |id| id[0] }
    i = 0
    while i+1 < idx.length

      start_first = idx[i][0]
      start_second = idx[i+1][0]
      end_first = idx[i][0]+idx[i][1]
      end_second = idx[i+1][0]+idx[i+1][1]

      if idx[i+1]
        if end_first >= start_second
          idx[i+1] = [ start_first, [end_first, end_second].max - start_first ]
          idx.delete_at(i)
        else
          i += 1
        end
      end
    end
    idx
  end

  # Returns a list of arrays, each with the [0] position that the mark should
  # begin and [1] the length of the word being highlighted.
  def self.get_highlight_indexes(text, word)
    return [] if text.blank?
    return [] if word.blank?

    text = text.clone
    indexes = []
    tt = ActiveSupport::Inflector.transliterate(text).downcase
    tw = ActiveSupport::Inflector.transliterate(word).downcase
    overall_i = 0

    while tt && i = tt.index(/#{Regexp.escape(tw)}/)
      if i
        overall_i += i
        indexes << [overall_i, tw.length]
        tt = tt[i + tw.length, tt.length - tw.length - i]
        overall_i += tw.length
      end
    end

    indexes
  end

  def self.set_highlight_on_indexes(text, indexes)
    result = ""
    begin_mark = "<mark>"
    end_mark = "</mark>"
    text_displacement = 0

    # We navigate the original text mounting a new result string with highlight marks to the
    # positions set in `indexes`. All the text outside and inside highlighted areas is escaped,
    # so that the only HTML in the resulting string will be the highlight marks.
    # The original string in `text` is not modified.
    indexes.each do |index_pair|

      # first is the position of the mark in the original text, second is
      # the length of the word/text being highlighted
      text_pos = index_pair[0]
      text_length = index_pair[1]

      # block before the mark
      if text_pos > text_displacement
        block = ERB::Util.html_escape(text[text_displacement..text_pos-1])
        result += block
      end

      # open highlight mark
      result += begin_mark

      # block inside the mark
      if text_length > 0
        block = ERB::Util.html_escape(text[text_pos..text_pos+text_length-1])
        result += block
      end
      text_displacement = text_pos + text_length

      # close highlight mark
      result += end_mark
    end

    # block after the last </mark>
    if text_displacement < text.length
      block = ERB::Util.html_escape(text[text_displacement..-1])
      result += block
    end

    result.html_safe
  end
end
