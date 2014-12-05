[1mdiff --git a/app/views/manage/_enabled_user.html.haml b/app/views/manage/_enabled_user.html.haml[m
[1mindex 3bf969b..7d05f1d 100644[m
[1m--- a/app/views/manage/_enabled_user.html.haml[m
[1m+++ b/app/views/manage/_enabled_user.html.haml[m
[36m@@ -16,7 +16,6 @@[m
           = link_to approve_user_path(user), :method => :post, :data => { :confirm => t('.approve_confirm') } do[m
             = icon_approve(:alt => t('.approve'), :title => t('.approve'))[m
 [m
[31m-[m
       - if !user.confirmed?[m
         = link_to confirm_user_path(user), :data => { :confirm => t('.confirm_confirm') },  :method => :post do[m
           = icon_confirm_user(:alt => t('.confirm'), :title => t('.confirm'))[m
