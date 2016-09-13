require './lib/mconf/mconf_resque'
class Queue::Normal < Queue::Mconf
  @queue = :normal
end

