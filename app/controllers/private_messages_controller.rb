# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessagesController < ApplicationController
  before_filter :private_message, :only => [:show, :update, :destroy]
  load_and_authorize_resource

  after_filter :only => [:create] do
    @private_message.new_activity unless @private_message.errors.any?
  end

  def index
    @page_size = 10
    if params[:sent]
      @private_messages = PrivateMessage.sent(user).paginate(:page => params[:page], :per_page => @page_size)
    else
      @private_messages = PrivateMessage.inbox(user).paginate(:page => params[:page], :per_page => @page_size)
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
    @receiver = User.find_by_id(@message.sender_id)
    @previous_messages = WillPaginate::Collection.create(params[:page], 5) do |pager|
      @previous_messages = PrivateMessage.previous(@message).reverse
      pager.replace(@previous_messages[pager.offset, pager.per_page])
      unless pager.total_entries
        pager.total_entries = @previous_messages.count
      end
    end
    if @is_receiver = user.id == @message.receiver_id
      @message.update_attributes(:checked => true)
    end
  end

  def new
    @private_message ||= PrivateMessage.new
    if params[:receiver]
      @receiver = User.find_by_id(params[:receiver])
    end
    if request.xhr?
      render :partial => 'form'
    else
      respond_to do |format|
        format.html { render :layout => "no_sidebar" }
        format.xml  { render :xml => @private_message }
      end
    end
  end

  # TODO: too big, probably can be reduced
  def create
    receivers = []
    if params[:private_message][:users_tokens]
      receivers = params[:private_message][:users_tokens].split(",")
    end
    @receivers = receivers.map {|receiver| { "id" => receiver.to_i, "name" => User.find(receiver).name} }
    unless receivers.empty?
      @success_messages = Array.new
      @fail_messages = Array.new
      for receiver in receivers.uniq
        params[:private_message][:sender_id] = user.id
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
          flash[:success] = t('message.created')
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
        else
          flash[:error] = t('message.error.create')
          format.html { render :action => "new" }
          format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
        end
      end
    else
      params[:private_message][:sender_id] = user.id
      @private_message = PrivateMessage.new(params[:private_message])
      if params[:private_message][:receiver_id]
        receiver = User.find(params[:private_message][:receiver_id])
        @receivers << { "id" => receiver.id, "name" => receiver.name }
      end
      respond_to do |format|
        if @private_message.save
          flash[:success] = t('message.created')
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
      if @private_message.update_attributes(params[:private_message])
        format.html { redirect_to(@private_message) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @private_message.update_attributes(params[:private_message])

    respond_to do |format|
      if params[:private_message][:deleted_by_sender]
        format.html { redirect_to(messages_path(:sent => true)) }
      else
        format.html { redirect_to(messages_path) }
      end
      format.xml  { head :ok }
    end
  end

  private

  def user
    @user = current_user
  end

  def private_message
    @private_message = PrivateMessage.find(params[:id])
  end
end
