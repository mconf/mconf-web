if defined?(Footnotes) && Rails.env.development?
  Footnotes.setup do |config|
    config.before do |controller, filter|
      if controller.class.name =~ /^LogoImages/
        controller.params[:footnotes] = "false" # disable footnotes
      end
    end
  end

  Footnotes.run!
end
