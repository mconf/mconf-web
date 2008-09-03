class TranslatorController < ApplicationController
  #this class is for using with the globalize plugin
  def index    
    @view_translations = ViewTranslation.find(:all, :conditions => [ 'built_in IS NULL AND language_id = ?', Locale.language.id ], :order => 'text')
  end

  def translation_text
    @translation = ViewTranslation.find(params[:id])
    render :text => @translation.text || ""  
  end

  def set_translation_text
    @translation = ViewTranslation.find(params[:id])
    previous = @translation.text
    @translation.text = params[:value]
    @translation.text = previous unless @translation.save
    render :partial => "translation_text", :object => @translation.text  
  end
end
