# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AdmissionObserver < ActiveRecord::Observer

  def after_create(admission)
    case admission
    when Invitation
      if (admission.group.class == Space) then
        Informer.deliver_invitation(admission)
      elsif (admission.group.class == Event) then
        Informer.deliver_event_invitation(admission)
      end
    when JoinRequest
      Informer.deliver_join_request(admission)
    end
  end

  def after_update(admission)
    if admission.processed?
      case admission
      when Invitation
        if (admission.group.class == Space) then
          Informer.deliver_processed_invitation(admission)
        elsif (admission.group.class == Event) then
          Participant.create({:user => admission.candidate, :email => admission.email, :event_id => admission.group.id, :attend => admission.accepted})
        end
      when JoinRequest
        Informer.deliver_processed_join_request(admission)
      end
    end
  end

end
