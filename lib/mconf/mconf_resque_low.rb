require './lib/mconf/mconf_resque'
class Queue::Low < Queue::Mconf
  @queue = :low
end