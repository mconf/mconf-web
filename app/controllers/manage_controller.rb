# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ManageController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: false

  before_filter :require_spaces_mod, only: [:spaces]

  def users
    words = params[:q].try(:split, /\s+/)
    query = User.with_disabled.search_by_terms(words, can?(:manage, User)).search_order

    [:disabled, :approved, :can_record].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    auth_methods = []
    auth_methods << :shibboleth if params[:login_method_shib] == 'true'
    auth_methods << :ldap if params[:login_method_ldap] == 'true'
    auth_methods << :certificate if params[:login_method_certificate] == 'true'
    auth_methods << :local if params[:login_method_local] == 'true'
    query = query.with_auth(auth_methods)

    if params[:admin].present?
      val = (params[:admin] == 'true') ? true : false
      query = query.superusers(val)
    end

    @users = query.paginate(page: params[:page], per_page: 40)

    if request.xhr?
      render partial: 'users_list', layout: false, locals: { users: @users }
    else
      render layout: 'manage'
    end
  end

  def spaces
    words = params[:q].try(:split, /\s+/)
    query = Space.with_disabled.search_by_terms(words, can?(:manage, Space)).search_order

    # start applying filters
    [:disabled, :approved].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    query = params[:tag] ? query.tagged_with(params[:tag]) : query

    @spaces = query.paginate(:page => params[:page], :per_page => 20)

    if request.xhr?
      render :partial => 'spaces_list', :layout => false, :locals => { :spaces => @spaces }
    else
      render :layout => 'manage'
    end
  end

  def recordings
    words = params[:q].try(:split, /\s+/)
    query = BigbluebuttonRecording.search_by_terms(words).search_order

    [:published, :available].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    if params[:playback] == "true"
      query = query.has_playback
    elsif params[:playback] == "false"
      query = query.no_playback
    end

    @totalSize = query.sum(:size)
    @recordings = query.paginate(page: params[:page], per_page: 20)

    if request.xhr?
      render partial: 'recordings_list', layout: false, locals: { recordings: @recordings }
    else
      render layout: 'manage'
    end
  end

  def check_statistics_params
    if params[:statistics].present?
      from = params[:statistics][:starts_on_time]
      to = params[:statistics][:ends_on_time]
      date_format = I18n.t('_other.datetimepicker.datepick_rails')

      @from_date = from.present? ? Date.strptime(from, date_format) : Time.at(0).utc
      @to_date = to.present? ? Date.strptime(to, date_format) : Time.now.utc
    else
      @from_date = Time.at(0).utc
      @to_date = Time.now.utc
    end
  end

  def statistics
    check_statistics_params
    @statistics = Mconf::StatisticsModule.generate(@from_date, @to_date)
  end

  def statistics_filter
    render layout: false
  end

  def statistics_csv
    check_statistics_params
    respond_to do |format|
      format.csv { send_data Mconf::StatisticsModule.generate_csv(@from_date, @to_date), type: Mime::CSV, disposition: "attachment", filename: "overview-from-#{@from_date.strftime('%m-%d-%Y')}-to-#{@to_date.strftime('%m-%d-%Y')}.csv" }
    end
  end
end
