# -*- coding: utf-8 -*-
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

# TODO: permissions
#       review

class PermissionsController < ApplicationController
  load_and_authorize_resource
  before_filter :subject

  def update
    # prevent forgery
    params[:permission].delete(:subject_id)
    params[:permission].delete(:subject_type)

    if @permission.update_attributes(params[:permission])
      if @permission.subject_type == 'Space'
        # TODO: permissions
        # Informer.delay.performance_update_notification(current_user, @performance.agent, @performance.stage, @performance.role.name)
      end
      respond_to do |format|
        format.html {
          flash[:success] = t('performance.updated')
          redirect_to request.referer
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @update_errors
          redirect_to request.referer
        }
      end
    end
  end

  private

  def subject
    @subject ||= @permission.subject
  end

end

#   def index
#     if stage.is_a?(Event)
#       @performances = stage.stage_performances + stage.container.stage_performances
#     else
#       performances
#     end

#     respond_to do |format|
#       format.xml  { render :xml => @performances }
#     end
#   end

#   def create
#     @performance = Performance.new(params[:performance])
#     @performance.stage = stage

#     if @performance.save
#       respond_to do |format|
#         format.html{
#           flash[:success] = t('role.added', :role => @performance.role.name, :agent => @performance.agent.name)
#           redirect_to request.referer
#         }
#         format.js {
#           performances
#         }
#       end
#     else
#       respond_to do |format|
#         format.html{
#           flash[:error] = @performance.errors.to_xml
#           redirect_to request.referer
#         }
#         format.js
#       end
#     end
#   end

  # def destroy
  #   @permission.destroy
  #   respond_to do |format|
  #     format.html {
  #       if can?(:read, @subject)
  #         redirect_to request.referer
  #       else
  #         redirect_to root_path
  #       end
  #     }
  #   end
  # end

#   #-#-# from station

#   include ActionController::StationResources

#   before_filter :stage, :only => [ :index, :new, :create ]
#   before_filter :performance, :only => [ :edit, :update, :destroy ]
#   before_filter :parse_polymorphic_agent, :only => [ :create, :update ]

#   def index
#     performances
#   end

#   def create
#     @performance = Performance.new(params[:performance])
#     @performance.stage = stage

#     if @performance.save
#       respond_to do |format|
#         format.html {
#           redirect_to(request.referer || [ @stage, Performance.new ])
#         }
#         format.js {
#           performances
#         }
#       end
#     else
#       respond_to do |format|
#         format.html {
#           redirect_to(request.referer || { :action => 'new' })
#         }
#         format.js
#       end
#     end
#   end

#   def update
#     # Prevent Performance forge
#     params[:performance].delete(:stage_id)
#     params[:performance].delete(:stage_type)

#     if @performance.update_attributes(params[:performance])
#       respond_to do |format|
#         format.html {
#           redirect_to [ stage, Performance.new ]
#         }
#         format.js {
#           performances
#         }
#       end
#     else
#       respond_to do |format|
#         format.html { render :action => 'edit' }
#         format.js
#       end
#     end
#   end

#   def destroy
#     @performance.destroy

#     respond_to do |format|
#       format.html {
#         redirect_to polymorphic_path([ @stage, Performance.new ])
#       }

#       format.js {
#         performances
#       }
#     end
#   end

#   def performance
#     @stage = resource.stage
#     resource
#   end

#   def performances
#     @performances = @stage.stage_performances.find(:all,
#                                                    :include => :role).sort{ |x, y| y.role <=> x.role }
#     @roles = @stage.class.roles.sort{ |x, y| y <=> x }
#     @roles = @roles.select{ |r| r <= @stage.role_for(current_user) } if @stage.role_for(current_user)

#     @agents = ActiveRecord::Agent.all - @performances.map(&:agent)
#   end

#   def parse_polymorphic_agent
#     return if params[:performance].blank?

#     if a = params[:performance].delete(:agent)
#       klass, id = a.split("-", 2)
#       params[:performance][:agent_id] = id
#       params[:performance][:agent_type] = klass.classify
#       unless ActiveRecord::Agent.symbols.include?(klass.pluralize.to_sym)
#         raise "Wrong Agent Type in PerformancesController: #{ h params[:performance][:agent_type] }"
#       end
#     end
#   end
