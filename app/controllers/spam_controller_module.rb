# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


module SpamControllerModule

  def spam
    @spam = resource
    @spam.update_attribute(:spam, true)
      if @spam.save
        Notifier.delay.spam_email(current_user,t('spam.detected'), params[:body], polymorphic_url(@spam))
        respond_to do |format|
          format.html {
            flash[:success] = t('spam.created')
            redirect_to request.referer
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = t('spam.error.check')
            render :action => "new"
          }
        end
      end
  end

  def spam_lightbox
    resource
    if request.xhr?
      render :layout => false
    end
  end

end
