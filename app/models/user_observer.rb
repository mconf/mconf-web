class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.deliver_confirmation_email(user)
  end

  def after_save(user)
    if user.class.password_recovery?
      Notifier.deliver_activation(user) if user.recently_activated?
      Notifier.deliver_lost_password(user) if user.recently_lost_password?
      Notifier.deliver_reset_password(user) if user.recently_reset_password?
    end
  end
end
