# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Controller
require_dependency "#{ Rails.root.to_s }/vendor/plugins/station/app/controllers/sources_controller"

class SourcesController
  before_filter :space!
  authorization_filter [ :create, :content ], :space

  def create
    @source = space.sources.build(params[:source])

    respond_to do |format|
      if @source.save
        flash[:notice] = t('source.created')
        format.html { redirect_to([ space, Source.new ]) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html {
          @sources = space.sources.reload
          flash[:error] = @source.errors.to_xml
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
