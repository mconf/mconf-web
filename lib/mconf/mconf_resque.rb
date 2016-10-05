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