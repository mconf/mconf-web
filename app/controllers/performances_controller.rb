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

class PerformancesController < ApplicationController
  authorization_filter :create, :performance, :only => [ :new, :create ]
  authorization_filter :read,   :performance, :only => [ :index, :show ]
  authorization_filter :update, :performance, :only => [ :edit, :update ]
  authorization_filter :delete, :performance, :only => [ :destroy ]

  def index
    if stage.is_a?(Event)
      @performances = stage.stage_performances + stage.container.stage_performances
    else
      performances
    end

    respond_to do |format|
      format.xml  { render :xml => @performances }
    end
  end

  def create
    @performance = Performance.new(params[:performance])
    @performance.stage = stage

    if @performance.save
      respond_to do |format|
        format.html{
          flash[:success] = t('role.added', :role => @performance.role.name, :agent => @performance.agent.name)
          redirect_to request.referer
        }
        format.js {
          performances
        }
      end
    else
      respond_to do |format|
        format.html{
          flash[:error] = @performance.errors.to_xml
          redirect_to request.referer
        }
        format.js
      end
    end
  end

  def update

    @update_errors=""
    if params[:update_groups]
      user=User.find(@performance.agent_id)
      space=Space.find(@performance.stage_id)

      #Groups to delete
      if params[:groups_to_delete]
        groups_to_delete = space.groups.select{|g| g.users.include?(user) && !params[:groups_to_delete].map{|a| a.to_i}.include?(g.id)}
      else
        groups_to_delete = space.groups.select{|g| g.users.include?(user)}
      end
      for group in groups_to_delete do
        group.user_ids -= [user.id]
        unless group.save
          @update_errors += group.errors + "</br>"
        end
      end

      #New groups added
      if params[:groups_to_add] && params[:groups_to_add][:id] != ""
        group = Group.find(params[:groups_to_add][:id])
        group.user_ids += [user.id]
        unless group.save
          @update_errors += group.errors + "</br>"
        end
      end
    end
    # Prevent Performance forge
    params[:performance].delete(:stage_id)
    params[:performance].delete(:stage_type)

    if @performance.update_attributes(params[:performance])

      if stage.type.name == 'Space'
        #Informer.delay.performance_update_notification(sender,receiver, stage, rol)
        Informer.delay.performance_update_notification(current_user, @performance.agent, @performance.stage, @performance.role.name)
      end

    else
      @update_errors += @performance.errors.to_xml + "</br>"
    end

    if @update_errors==""
      respond_to do |format|
        format.html {
          flash[:success] = t('performance.updated')
          redirect_to request.referer
        }
        format.js {

        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @update_errors
          redirect_to request.referer
        }
        format.js{
        }
      end
    end
  end

  def destroy
    @performance.destroy

    respond_to do |format|
      format.html {
        redirect_to(@performance.stage.authorize?(:read, :to => current_user) ? request.referer : root_path)
      }

      format.js {
        performances
      }
    end
  end

  #-#-# from station

  include ActionController::StationResources

  before_filter :stage, :only => [ :index, :new, :create ]
  before_filter :performance, :only => [ :edit, :update, :destroy ]
  before_filter :parse_polymorphic_agent, :only => [ :create, :update ]

  def index
    performances
  end

  def create
    @performance = Performance.new(params[:performance])
    @performance.stage = stage

    if @performance.save
      respond_to do |format|
        format.html {
          redirect_to(request.referer || [ @stage, Performance.new ])
        }
        format.js {
          performances
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to(request.referer || { :action => 'new' })
        }
        format.js
      end
    end
  end

  def update
    # Prevent Performance forge
    params[:performance].delete(:stage_id)
    params[:performance].delete(:stage_type)

    if @performance.update_attributes(params[:performance])
      respond_to do |format|
        format.html {
          redirect_to [ stage, Performance.new ]
        }
        format.js {
          performances
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js
      end
    end
  end

  def destroy
    @performance.destroy

    respond_to do |format|
      format.html {
        redirect_to polymorphic_path([ @stage, Performance.new ])
      }

      format.js {
        performances
      }
    end
  end

  private

  def stage
    @stage ||= record_from_path(:acts_as => :stage)
  end

  def performance
    @stage = resource.stage
    resource
  end

  def performances
    @performances = @stage.stage_performances.find(:all,
                                                   :include => :role).sort{ |x, y| y.role <=> x.role }
    @roles = @stage.class.roles.sort{ |x, y| y <=> x }
    @roles = @roles.select{ |r| r <= @stage.role_for(current_user) } if @stage.role_for(current_user)

    @agents = ActiveRecord::Agent.all - @performances.map(&:agent)
  end

  def parse_polymorphic_agent
    return if params[:performance].blank?

    if a = params[:performance].delete(:agent)
      klass, id = a.split("-", 2)
      params[:performance][:agent_id] = id
      params[:performance][:agent_type] = klass.classify
      unless ActiveRecord::Agent.symbols.include?(klass.pluralize.to_sym)
        raise "Wrong Agent Type in PerformancesController: #{ h params[:performance][:agent_type] }"
      end
    end
  end

end
