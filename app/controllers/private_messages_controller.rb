class PrivateMessagesController < ApplicationController

  # GET /private_messages
  # GET /private_messages.xml
  def index
    @private_messages = PrivateMessage.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @private_messages }
    end
  end

  # GET /private_messages/new
  # GET /private_messages/new.xml
  def new
    
    @private_message = PrivateMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @private_message }
    end
  end

  # GET /private_messages/1/edit
  def edit
    @private_message = PrivateMessage.find(params[:id])
  end

  # POST /private_messages
  # POST /private_messages.xml
  def create
    @private_message = PrivateMessage.new(params[:private_message])

    respond_to do |format|
      if @private_message.save
        flash[:notice] = 'PrivateMessage was successfully created.'
        format.html { redirect_to(@private_message) }
        format.xml  { render :xml => @private_message, :status => :created, :location => @private_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @private_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /private_messages/1
  # PUT /private_messages/1.xml
  def update
    @private_message = PrivateMessage.find(params[:id])

    respond_to do |format|
      if @private_message.update_attributes(params[:private_message])
        flash[:notice] = 'PrivateMessage was successfully updated.'
        format.html { redirect_to(@private_message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @private_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /private_messages/1
  # DELETE /private_messages/1.xml
  def destroy
    @private_message = PrivateMessage.find(params[:id])
    @private_message.destroy

    respond_to do |format|
      format.html { redirect_to(private_messages_url) }
      format.xml  { head :ok }
    end
  end
end
