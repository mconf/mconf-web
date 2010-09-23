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


class AgendasController < ApplicationController
  include ActionController::StationResources
  
  before_filter :space!
  before_filter :event
  before_filter :agenda

  authorization_filter :create, :agenda, :only => [ :new, :create ]
  authorization_filter :read,   :agenda, :only => [ :index, :show ]
  authorization_filter :update, :agenda, :only => [ :edit, :update ]
  authorization_filter :delete, :agenda, :only => [ :destroy ]
  
  # GET /agenda/edit
  def edit
    @agenda_day = (params[:day].present? && params[:day].to_i <= @event.days) ?
                  @event.start_date + (params[:day].to_i - 1).day :
                  @event.start_date
  end
  
  # GET /agendas/1
  # GET /agendas/1.xml
  #returns the agenda_entries for the days 2 to end by ajax
  def show
    @days = (1..@event.days).to_a
    if @event.days > 1   
      unless params[:page_shown]
        params[:page_shown]="1"
      end
      #the agenda has shown params[:page_shown], let's remove it from the pages to be shown     
      @days.delete(params[:page_shown])
    end
    respond_to do |format|
      if request.xhr?
        format.js
      else
        format.html { redirect_to [ @event.space, @event ] }
      end
    end 
  end
  
  
  
  # POST /agendas
  # POST /agendas.xml
  def create
    
    respond_to do |format|
      #if @event.update_attributes(params[:agenda])
      #if true
      if @agenda.update_attributes(params[:agenda])
        if !@agenda.notices.nil?
          flash[:notice] = @agenda.notices
        end
        format.html { redirect_to(space_event_path(@space, @event)) }
      else
        flash[:error] = @agenda.errors.to_xml
        format.html { redirect_to(space_event_path(@space, @event)) }
        #format.html { redirect_to(space_event_path(@space, @event, :show_day => 1)) }
      end
    end

    
  end
  
  
  def update
        respond_to do |format|
      #if @event.update_attributes(params[:agenda])
      #if true
      if @agenda.update_attributes(params[:agenda])
        if params[:in_steps]
          format.html { redirect_to(space_event_path(@space, @event, :invitations => @event)) } 
        else
          format.html { redirect_to(space_event_path(@space, @event)) } 
        end
        
      else
        format.html { redirect_to(space_event_path(@space, @event)) }
        #format.html { redirect_to(space_event_path(@space, @event, :show_day => 1)) }
      end
    end
  end
  
private

 
  def event
    @event = Event.find_by_permalink(params[:event_id]) || raise(ActiveRecord::RecordNotFound)
  end
  
  def space!
    @space = Space.find_by_permalink(params[:space_id])
  end

  def agenda
    @agenda = @event.agenda
  end

  
=begin
  # GET /agendas
  # GET /agendas.xml
  def index
    @agendas = Agenda.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agendas }
    end
  end

  # GET /agendas/1
  # GET /agendas/1.xml
  def show
    @agenda = Agenda.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agenda }
    end
  end

  # GET /agendas/new
  # GET /agendas/new.xml
  def new
    @agenda = Agenda.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agenda }
    end
  end

  # GET /agendas/1/edit
  def edit
    @agenda = Agenda.find(params[:id])
  end

  # PUT /agendas/1
  # PUT /agendas/1.xml
  def update
    @agenda = Agenda.find(params[:id])

    respond_to do |format|
      if @agenda.update_attributes(params[:agenda])
        flash[:notice] = 'Agenda was successfully updated.'
        format.html { redirect_to(@agenda) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agenda.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agendas/1
  # DELETE /agendas/1.xml
  def destroy
    @agenda = Agenda.find(params[:id])
    @agenda.destroy

    respond_to do |format|
      format.html { redirect_to(agendas_url) }
      format.xml  { head :ok }
    end
  end
=end




end
