# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PrivateMessagesController < ApplicationController
  before_filter :private_message, :only => [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    if params[:sent_messages]
      @private_messages = PrivateMessage.sent(user).paginate(:page => params[:page], :per_page => 10)
    else  
      @private_messages = PrivateMessage.inbox(user).paginate(:page => params[:page], :per_page => 10)
    end

    #search the name of the user when replying a message
    if params[:reply_to]
      @previous_message = PrivateMessage.find(params[:reply_to])
      @receiver_name = User.find(@previous_message.sender_id).name
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @private_messages }
    end
  end

  def show
    @show_message = PrivateMessage.find(params[:id])
    @previous_message = @show_message
    @receiver_name = User.find(@show_message.sender_id).name
    @previous_messages = []
    previous = @show_message 
    while previous.parent_id
      previous = PrivateMessage.find(previous.parent_id)
      @previous_messages << previous
    end
    if @is_receiver = user.id == @show_message.receiver_id
      @show_message.checked = true
      @show_message.save
    end
    
  end

  def new
       
    @private_message = PrivateMessage.new
    if params[:receiver]
      @receiver_name = User.find(params[:receiver]).name
    end
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
      format.xml  { render :xml => @private_message }
    end
  end

  # GET /private_messages/1/edit
  def edit
  end

  def create
    receivers = []
    if params[:private_message][:users_tokens]
      receivers = params[:private_message][:users_tokens].split(",")
    end
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
          format.html { redirect_to request.referer }
          format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
        end
      end
    else  
      params[:private_message][:sender_id] = user.id
      @private_message = PrivateMessage.new(params[:private_message])
  
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
    @private_message.update_attributes(params[:private_message])

    respond_to do |format|
      if params[:private_message][:deleted_by_sender]
        format.html { redirect_to(user_messages_path(user, :sent_messages=>true)) }
      else
        format.html { redirect_to(user_messages_path(user)) }
      end
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
