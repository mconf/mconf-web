class AgendaRecordEntriesController < ApplicationController
 
=begin
  # GET /agenda_record_entries
  # GET /agenda_record_entries.xml
  def index
    @agenda_record_entries = AgendaRecordEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agenda_record_entries }
    end
  end

  # GET /agenda_record_entries/1
  # GET /agenda_record_entries/1.xml
  def show
    @agenda_record_entry = AgendaRecordEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agenda_record_entry }
    end
  end

  # GET /agenda_record_entries/new
  # GET /agenda_record_entries/new.xml
  def new
    @agenda_record_entry = AgendaRecordEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agenda_record_entry }
    end
  end

  # GET /agenda_record_entries/1/edit
  def edit
    @agenda_record_entry = AgendaRecordEntry.find(params[:id])
  end

  # POST /agenda_record_entries
  # POST /agenda_record_entries.xml
  def create
    @agenda_record_entry = AgendaRecordEntry.new(params[:agenda_record_entry])

    respond_to do |format|
      if @agenda_record_entry.save
        flash[:notice] = 'AgendaRecordEntry was successfully created.'
        format.html { redirect_to(@agenda_record_entry) }
        format.xml  { render :xml => @agenda_record_entry, :status => :created, :location => @agenda_record_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agenda_record_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agenda_record_entries/1
  # PUT /agenda_record_entries/1.xml
  def update
    @agenda_record_entry = AgendaRecordEntry.find(params[:id])

    respond_to do |format|
      if @agenda_record_entry.update_attributes(params[:agenda_record_entry])
        flash[:notice] = 'AgendaRecordEntry was successfully updated.'
        format.html { redirect_to(@agenda_record_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agenda_record_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agenda_record_entries/1
  # DELETE /agenda_record_entries/1.xml
  def destroy
    @agenda_record_entry = AgendaRecordEntry.find(params[:id])
    @agenda_record_entry.destroy

    respond_to do |format|
      format.html { redirect_to(agenda_record_entries_url) }
      format.xml  { head :ok }
    end
  end
=end

end
