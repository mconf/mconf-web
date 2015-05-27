module Mconf

  def self.generate_dial_number opt={}
    pattern = opt[:pattern] || Site.current.try(:room_dial_number_pattern)
    sym = opt[:symbol] || 'x'

    # For each 'x' (sym) in the pattern text
    # substitute it for a random integer in [0-9]
    result = pattern

    if pattern.present?
      pattern.count(sym).times do
        result.sub!(sym, Kernel.rand(10).to_s)
      end
    end

    result
  end

end