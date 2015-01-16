# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessagesController < ApplicationController
  load_and_authorize_resource

  def index
    @page_size = 10
    if params[:sent]
      @private_messages = PrivateMessage.sent(current_user).paginate(:page => params[:page], :per_page => @page_size)
    else
      @private_messages = PrivateMessage.inbox(current_user).paginate(:page => params[:page], :per_page => @page_size)
    end

    # search the name of the user when replying a message
    if params[:reply_to]
      @previous_message = PrivateMessage.find(params[:reply_to])
      @receiver = User.find(@previous_message.sender_id)
    end

    respond_to do |format|
      format.html { render :layout => "no_sidebar" }
      format.xml  { render :xml => @private_messages }
    end
  end

  def show
    @message = PrivateMessage.find(params[:id])
    params[:page] ||= 1
    @previous_message = @message #this is to the reply message partial
    @receiver = @message.sender
    @previous_messages = WillPaginate::Collection.create(params[:page], 5) do |pager|
      @previous_messages = PrivateMessage.previous(@message).reverse
      pager.replace(@previous_messages[pager.offset, pager.per_page])
      unless pager.total_entries
        pager.total_entries = @previous_messages.count
      end
    end
    @is_receiver = current_user.id == @message.receiver_id
    if @is_receiver
      @message.update_attributes(:checked => true)
    end
  end

  def new
    @private_message ||= PrivateMessage.new
    if params[:receiver]
      @receiver = User.find(params[:receiver])
    end
    if request.xhr?
      render :partial => 'form'
    else
      render :layout => "no_sidebar"
    end
  end

  # TODO: too big, probably can be reduced
  def create
    receivers = []

    if params[:private_message][:users_tokens]
      receivers = params[:private_message][:users_tokens].split(",")
    end

    unless receivers.blank?
      receivers.map! {|r| User.find(r)}
      @success_messages = []
      @fail_messages = []
      for receiver in receivers.uniq
        private_message = PrivateMessage.new(private_message_params)
        private_message.sender_id = current_user.id
        private_message.receiver_id = receiver.id
        if private_message.save
          @success_messages << private_message
        else
          @fail_messages << private_message
        end
      end

      respond_to do |format|
        if @fail_messages.empty?
          flash[:success] = t('message.created')
          format.html { redirect_to request.referer }
        else
          flash[:error] = t('message.error.create')
          format.html { render :action => "new" }
        end
      end

    else
      @private_message = PrivateMessage.new(private_message_params)
      @private_message.sender = current_user

      if @private_message.receiver
        receiver = @private_message.receiver
        receivers << { "id" => receiver.id, "name" => receiver.name }
      end

      respond_to do |format|
        if @private_message.save
          flash[:success] = t('message.created')
          format.html { redirect_to request.referer }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @private_message.update_attributes(private_message_params)
        format.html { redirect_to(@private_message) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @private_message.update_attributes(private_message_params)
    respond_to do |format|
      sent = params[:private_message][:deleted_by_sender].present? ? true : nil
      format.html { redirect_to(messages_path(:sent => sent)) }
    end
  end

  private

  def private_message_params
    unless params[:private_message].blank?
      params[:private_message].except(excepted_params).permit(*allowed_params)
    else
      {}
    end
  end

  def excepted_params
    [:sender_id, :users_tokens]
  end

  def allowed_params
    [:title, :body, :parent_id, :receiver_id, :deleted_by_sender, :deleted_by_receiver]
  end
end
