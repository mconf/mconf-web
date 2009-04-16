class PrivateMessagesController < ApplicationController
  
  before_filter :private_message, :only => [:check, :edit, :update]
  
  authorization_filter [ :manage, :message ], :user
  authorization_filter [ :forbidden_edit, :message ], :user, :only => [ :edit ]

  def index
    if params[:sent_messages]
      @private_messages = PrivateMessage.find_all_by_sender_id(params[:user_id], :order => "created_at DESC").paginate(:page => params[:page], :per_page => 10)
    else  
      @private_messages = PrivateMessage.find_all_by_receiver_id(params[:user_id], :order => "created_at DESC").paginate(:page => params[:page], :per_page => 10)
    end
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @private_messages }
    end
  end

  def show
    @show_message = PrivateMessage.find(params[:id])
    @show_message.checked = true
    @show_message.save
  end

  def new
    
    @private_message = PrivateMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @private_message }
    end
  end

  # GET /private_messages/1/edit
  def edit
  end

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

  def update

    respond_to do |format|
      if @success_update = @private_message.update_attributes(params[:private_message])
        format.html { redirect_to(@private_message) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @private_message.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /private_messages/1
  # DELETE /private_messages/1.xml
  def destroy
    @private_message = PrivateMessage.find(params[:id])
    @private_message.destroy

    respond_to do |format|
      format.html { redirect_to(user_messages_path(params[:user_id])) }
      format.xml  { head :ok }
    end
  end

  private

  def user
    @user ||= User.find_with_param(params[:user_id])
  end
  
  def private_message
    @private_message = PrivateMessage.find(params[:id])
  end
end
