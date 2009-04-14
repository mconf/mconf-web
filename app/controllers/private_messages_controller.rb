class PrivateMessagesController < ApplicationController
  authorization_filter [ :manage, :message ], :user

  # GET /private_messages
  # GET /private_messages.xml
  def index
    if params[:sent_messages]
      @private_messages = PrivateMessage.find_all_by_sender_id(params[:user_id])
    else  
      @private_messages = PrivateMessage.find_all_by_receiver_id(params[:user_id])
    end
    

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
    if params[:receiver_ids]
      @success_messages = Array.new
      @fail_messages = Array.new
      for receiver in params[:receiver_ids].uniq
        params[:private_message][:sender_id] = params[:user_id]
        params[:private_message][:receiver_id] = receiver
        private_message = PrivateMessage.new(params[:private_message])
        if private_message.save
          @success_messages << private_message
        else
          @fail_messages << private_message
        end
      end
      respond_to do |format|
        if @fail_messages.empty?
          flash[:success] = 'PrivateMessages were successfully created.'
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
        else
          flash[:error] = 'Error sending private messages.'
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
        end
      end
    else  
      params[:private_message][:sender_id] = params[:user_id]
      @private_message = PrivateMessage.new(params[:private_message])
  
      respond_to do |format|
        if @private_message.save
          flash[:success] = 'PrivateMessage was successfully created.'
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @private_message, :status => :created, :location => @private_message }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @private_message.errors, :status => :unprocessable_entity }
        end
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

  private

  def user
    @user ||= User.find_with_param(params[:user_id])
  end
end
