class Forgery::Basic < Forgery

  def self.unique_text(n, options={})
    "#{self.text(options)} #{n}"
  end

end
