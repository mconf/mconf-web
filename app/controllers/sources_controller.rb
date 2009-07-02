# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/sources_controller"

class SourcesController
  before_filter :space!
  authorization_filter [ :create, :content ], :space

  def create
    @source = space.sources.build(params[:source])

    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to([ space, Source.new ]) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html {
          @sources = space.sources.reload
          render :action => "index"
        }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Have to rewrite this method because space_news_index_path is not correctly inferred, because of singularization
  def import
    @source = Source.find(params[:id])
    @source.import

    redirect_to ( @source.target == "News" ? 
                 space_news_index_path(@source.container) :
                 [ @source.container, @source.target.constantize.new ])
  end
end
