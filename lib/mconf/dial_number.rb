# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class DialNumber
    def self.get_current
      current = Site.current.current_room_dial_number_pattern

      if current.blank?
        Site.current.update_attributes(current_room_dial_number_pattern: 0)
        current = 0
      end

      current
    end

    def self.generate(pattern=nil, opt={})
      return nil if pattern.nil?
      sym = get_symbol(opt)

      start_from = opt[:current] || get_current

      # Don't generate the number if it would require more than the number of free symbol spaces
      if start_from.to_s.size <= pattern.count(sym)
        result = get_dial_number_from_ordinal(start_from, pattern, opt)

        # increment the current pattern
        Site.current.increment!(:current_room_dial_number_pattern) unless opt[:current].present?
      end

      result
    end

    def self.get_dial_number_from_ordinal(ordinal, pattern=nil, opt={})
      return nil if pattern.nil?
      sym = get_symbol(opt)

      number_size = pattern.count(sym)
      ordinal_str = ordinal.to_s.rjust(number_size,'0').reverse
      dial_number = pattern.reverse

      ordinal_str.each_char do |n|
        dial_number.sub!(sym, n)
      end

      dial_number.reverse
    end

    def self.get_ordinal_from_dial_number(number, pattern=nil, opt={})
      return nil if pattern.nil?
      sym = get_symbol(opt)

      regexp = Regexp.new(pattern.gsub(sym, '([0-9])')) # make a pattern to capture only the numbers
      match = regexp.match(number) # extract only the numbers

      # join the numbers and turn then into an ordinal integer
      ordinal = match[1, match.size].join.to_i if match.present?

      ordinal
    end

    def self.get_symbol opt
      opt[:symbol] || 'x'
    end
  end
end
