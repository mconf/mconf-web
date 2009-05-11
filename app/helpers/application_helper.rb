# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 def menu(tab)
   @menu_tab = tab
 end

 def menu_options(tab, options = {})
   @menu_tab == tab ?
     options.update({ :class => 'selected' }) :
     options
 end
end
