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


module SpamControllerModule 
   
  def spam
    @spam = resource
    @spam.update_attribute(:spam, true)
      if @spam.save
        Notifier.spam_email(current_user,t('spam.detected'), params[:body], polymorphic_url(@spam)).deliver
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
