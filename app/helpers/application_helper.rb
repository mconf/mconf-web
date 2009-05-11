# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 
 def my_spaces()
   current_user.stages.sort_by{|s| s[:name]}
 end
 
 def other_public_spaces(user_spaces)
   Space.all(:conditions => {:public => true}, :order => :name) - user_spaces
 end

 def menu(tab)
   @menu_tab = tab
 end

 def menu_options(tab, options = {})
   @menu_tab == tab ?
     options.update({ :class => 'selected' }) :
     options
 end
end
