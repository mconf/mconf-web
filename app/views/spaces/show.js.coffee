# Renders the partial with the last news posted in the space
new_content = '<%= escape_javascript(render(:partial => "latest_news"))%>'
$("#latest-news").replaceWith(new_content)
