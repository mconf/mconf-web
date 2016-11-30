# Based on https://www.sitepoint.com/simple-organized-queueing-with-resque/
class Queue::Mconf
  class << self
    def enqueue(object, method, *args)
      meta = { 'method' => method }
      if is_model?(object)
        Resque.enqueue(self, meta.merge('class' => object.class.name, 'id' => object.id), *args)
      else
        Resque.enqueue(self, meta.merge('class' => object.name), *args)
      end
    end

    def perform(meta = { }, *args)
      if meta.has_key?('id')
        if model = meta['class'].constantize.find_by_id(meta['id'])
          model.send(meta['method'], *args)
        end
      else
        meta['class'].constantize.send(meta['method'], *args)
      end
    end

    def is_model?(object)
      object.class.respond_to?(:find_by_id)
    end
  end
end

class Queue::High < Queue::Mconf
  @queue = :high
end

class Queue::Normal < Queue::Mconf
  @queue = :normal
end

class Queue::Low < Queue::Mconf
  @queue = :low
end
