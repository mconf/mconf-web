# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


module SpamControllerModule

  def spam_report_create
    @spam = resource_for_spam
    @spam.update_attribute(:spam, true)
    if @spam.save
      respond_to do |format|
        format.html {
          flash[:success] = t('spam.spam_report_create.success')
          redirect_to request.referer
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = t('spam.spam_report_create.error')
          render :action => "new"
        }
      end
    end
  end

end
