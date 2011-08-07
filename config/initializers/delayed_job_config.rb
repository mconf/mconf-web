# Delayed::Worker.destroy_failed_jobs = true
# Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 10 # default 25
# Delayed::Worker.max_run_time = 4.hours
Delayed::Worker.delay_jobs = !Rails.env.test?
