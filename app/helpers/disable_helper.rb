# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module DisableHelper

  def disable_links classname, object, translations=nil

    if object.enabled? && can?(:disapprove, object)

      link_to send("disable_#{classname}_path", object), :method => :post, :data => { :confirm => t('.disable_confirm') } do
        icon_disapprove(:alt => t('.disapprove'), :title => t('.disapprove'))
      end

    elsif !object.approved? && can?(:approve, object)

      link_to send("approve_#{classname}_path", object), :method => :post, :data => { :confirm => t('.enable_confirm') } do
        icon_approve(:alt => t('.approve'), :title => t('.approve'))
      end

    end

  end

end
