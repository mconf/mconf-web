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

require 'bigbluebutton-api'

class HomesController < ApplicationController
  
  before_filter :authentication_required

  def index
  end
  
  def show
    @server = BigbluebuttonServer.first
    @bbb_room = BigbluebuttonRoom.where("owner_id = ? AND owner_type = ?", current_user.id, current_user.class.name)
    
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date ASC")
    end
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
  end

  def new_room
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  def create_room
    room = BigbluebuttonRoom.new(:name => params[:home][:title], :meeting_id => params[:home][:title],
                                 :owner => current_user, :server => BigbluebuttonServer.first)
                                
    respond_to do |format|
      if room.save
        flash[:success] = t('room.created')
        format.html { redirect_to :action => "show" }
      else
        flash[:error] = t('room.error.create') << " ( " << room.errors.full_messages.join(', ') << " )"
        format.html { redirect_to :action => "show" }
      end
    end
  end

  def invite_room
    @room_name = params[:roomName]
    tags = []
    members = Profile.where("full_name like ?", "%#{params[:q]}%").select(['full_name', 'id'])
    members.each do |f| 
      tags.push("id"=>f.id, "name"=>f.full_name)
    end
    
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
      format.json { render :json => tags }
    end
  end
  
  def send_invite
    @success_messages = Array.new
    @fail_messages = Array.new
    
    priv_msg = Hash.new
    priv_msg[:sender_id] = current_user.id
    
    if(params[:home][:message].empty?)
      priv_msg[:body] = "Invite for Webconference."
    else
      priv_msg[:body] = params[:home][:message]
    end
    
    #editar texto para receber link
    
    title = ""
    title << "Invite for webconference"
    priv_msg[:title] = title
    priv_msg[:email_sender] = current_user.email
    
    if(params[:home][:im_check])
      for receiver in params[:home][:members_tokens].split(",")
        priv_msg[:receiver_id] = receiver
        private_message = PrivateMessage.new(priv_msg)
        if private_message.save
          @success_messages << private_message
        else
          @fail_messages << private_message
        end
      end
    end
    
    if(params[:home][:email_check])
      for receiver in params[:home][:email_tokens].split(",")
        priv_msg[:email_receiver] = receiver
        Notifier.webconference_invite_email(priv_msg).deliver
      end
    end
    
    
    respond_to do |format|
      if params[:home][:im_check]
        if @fail_messages.empty?
          flash[:success] = t('message.created')
          format.html { redirect_to :action => "show" }
          format.xml  { render :xml => @success_messages, :status => :created, :location => @success_messages }
        else
          flash[:error] = t('message.error.create')
          format.html { redirect_to :action => "show" }
          format.xml  { render :xml => @fail_messages.map{|m| m.errors}, :status => :unprocessable_entity }
        end
        else
          format.html { redirect_to :action => "show" }
      end
    end
    
  end

end