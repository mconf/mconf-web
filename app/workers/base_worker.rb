class BaseWorker
  # Make everyone who inherits from BaseWorker an exclusive lock worker
  # In the future if we change libs or need to add more stuff, change only here
  extend Resque::Plugins::LockTimeout

end
