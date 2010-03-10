module ActionController #:nodoc:
  module Logos
    class << self
      def included(base) #:nodoc:
        base.send :include, ActionController::Station unless base.ancestors.include?(ActionController::Station)
      end
    end

    def show
      @logo = ( 
        @logoable ? 
        @logoable.logo : 
        model_class.find(params[:id]) 
      )

      @logo = 
        @logo.thumbnails.find_by_thumbnail(params[:thumbnail]) if params[:thumbnail]

      case @logo.attachment_options[:storage]
      when :file_system
        send_file @logo.full_filename, :type => @logo.content_type,
                                       :disposition => 'inline'
      when :db_file
        send_data @logo.current_data, :filename => @logo.filename,
                                      :type => @logo.content_type,
                                      :disposition => 'inline'
      else
        raise "Storage type not supported. Patches are wellcome!"
      end

    end

    private

    def get_logoable_from_path #:nodoc:
      record_from_path(:acts_as => :logoable)
    end
  end
end
