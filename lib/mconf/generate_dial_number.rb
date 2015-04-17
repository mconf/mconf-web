module Mconf

  def self.generate_dial_number pattern=nil
    pattern ||= Site.current.try(:room_dial_number_pattern)
    result = pattern

    if pattern.present?
      pattern.count('x').times { result.sub!('x', rand(10).to_s) }
    end

    result
  end

end