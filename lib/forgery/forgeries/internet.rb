class Forgery::Internet < Forgery
  def self.unique_email_address(n)
    user_name + n.to_s + '@' + domain_name
  end

  def self.unique_user_name(n)
    "#{self.user_name}-#{n}"
  end

  def self.unique_permalink(p)
    unique_user_name(p)
  end
end
