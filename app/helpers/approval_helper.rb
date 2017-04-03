# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module ApprovalHelper

  def approval_links classname, object
    link = lambda { |action|
      link_to send("#{action}_#{classname}_path", object), :method => :post, :data => { :confirm => t(".#{action}_confirm") } do
        send("icon_#{action}" ,:alt => t(".#{action}"), :title => t(".#{action}"))
      end
    }

    if object.approved? && can?(:disapprove, object)
      link.call('disapprove')
    elsif !object.approved? && can?(:approve, object)
      link.call('approve')
    end
  end

end
