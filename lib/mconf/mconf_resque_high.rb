require './lib/mconf/mconf_resque'
class Queue::High < Queue::Mconf
  @queue = :high
end

