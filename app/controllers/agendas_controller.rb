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
  before_filter :space!
  before_filter :event
  
  # GET /agenda/edit
  def edit
    @agenda_entry = AgendaEntry.new
  end
  
  # POST /agendas
  # POST /agendas.xml
  def create
    if params[:icalendar_file].present?
     #flash[:notice] = t('icalendar.succes_import')

     import_icalendar
          
     redirect_to(space_event_path(@space, @event))
     return
    end
    
   respond_to do |format|
        format.html { redirect_to(space_event_path(@space, @event, :show_day => 1)) }
   end


    
  end
  
private
  
  def event
    @event = Event.find_by_permalink(params[:event_id])
  end
  
  def space!
    @space = Space.find_by_permalink(params[:space_id])
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



def import_icalendar
  
    begin
      @icalendar = params[:icalendar_file][:data]    
      @icalendar = Vpim::Icalendar.decode(@icalendar)
      overwrite = false;     
      
      if params[:overwrite].present? #overwrite
        overwrite = true;     
        @event.agenda.destroy    
        agenda = Agenda.new()
        @event.agenda = agenda
      else #o just add
        agenda = @event.agenda
      end
      
      has_updated = false;
      has_conflict = false;
      has_outofbounds = false;
      updated_entries = Array.new();
      conflictive_entries = Array.new();
      outofbounds_entries = Array.new();
      total_entries = Array.new();
      
      @icalendar.each do |cal|
     
        entries = cal.events
        
        
        entries.each do |e|
          
          if !overwrite && !(agenda_entry = AgendaEntry.find(:first, :conditions => ["agenda_id = ? AND uid = ?", agenda.id, e.uid])).nil?
            if agenda_entry.updated_at == agenda_entry.created_at #Not modified on VCC
              has_updated = true;
              updated_entries.push(agenda_entry.title)
              agenda_entry.destroy; #update
            else #Modified on VCC, conflict and error
              has_conflict = true;
              conflictive_entries.push(agenda_entry.title)
              next;
            end
          end
          
                             
          agenda_entry = AgendaEntry.new()
          
          agenda_entry.agenda = agenda
          
          agenda_entry.title = e.summary.to_s
          agenda_entry.description = e.description.to_s
          agenda_entry.start_time = e.dtstart.to_s
          agenda_entry.end_time = e.dtend.to_s
          agenda_entry.speakers = e.organizer.to_s
          agenda_entry.uid = e.uid        
          
          if (!((@event.start_date < agenda_entry.start_time)&&(@event.end_date > agenda_entry.end_time)))
            has_outofbounds = true;
            outofbounds_entries.push(agenda_entry.title)
            next;
          end           
           
          agenda_entry.save!
          total_entries.push(agenda_entry.title);
         
        end     
        
      end
      
    flash[:notice] = t("icalendar.succes_import")  + "<br>"
    
    if has_updated && !overwrite
      if updated_entries.length == 1 
        flash[:notice] = flash[:notice] + "<br>" + t("icalendar.updated1")
      else        
        flash[:notice] = flash[:notice] + "<br>" + updated_entries.length.to_s + t("icalendar.updatedn")
      end 
    end    
    
    if has_conflict && !overwrite
      if conflictive_entries.length == 1 
        flash[:notice] = flash[:notice] + "<br>" + t("icalendar.conflictive1")
      else        
        flash[:notice] = flash[:notice] + "<br>" + conflictive_entries.length.to_s + t("icalendar.conflictiven")
      end 
    end 
    
    if has_outofbounds
      if outofbounds_entries.length == 1 
        flash[:notice] = flash[:notice] + "<br>" + t("icalendar.outbounds1")
      else        
        flash[:notice] = flash[:notice] + "<br>" + outofbounds_entries.length.to_s + t("icalendar.outboundsn")
      end 
    end 
 
    flash[:notice] = flash[:notice] + "<br>"+ t("icalendar.importMessage1") + (outofbounds_entries.length + conflictive_entries.length + total_entries.length).to_s +
     t("icalendar.importMessage2") + total_entries.length.to_s  + t("icalendar.importMessage3")

  
    rescue Exception => exc
      flash[:error] = t("icalendar.error_import") + "<br>" + t("icalendar.importMessage4") + exc.message
    end
  end
end
