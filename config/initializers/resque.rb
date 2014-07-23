class CanAccessResque

  def self.matches?(request)
    current_user = request.env['warden'].user
    return false if current_user.blank?
    Abilities.ability_for(current_user).can? :manage, Resque
  end

end
