class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.deliver_confirmation_email(user)
  end

  def after_save(user)
    Notifier.deliver_forgot_password(user) if user.recently_forgot_password?
    Notifier.deliver_reset_password(user) if user.recently_reset_password?
  end
end
