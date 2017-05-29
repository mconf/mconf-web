# Start and configure email tracking
AhoyEmail.track(
  utm_params: false,
  open: Rails.application.config.email_track_opened,
  click: Rails.application.config.email_track_clicked
)
