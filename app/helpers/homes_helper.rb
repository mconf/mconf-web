module HomesHelper

  def intervals(contents)
    today = {:contents => contents.select{|x| x.updated_at > Date.yesterday}, :name => t('today')}
    yesterday = {:contents => contents.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}, :name => t('yesterday')}
    last_week = {:contents => contents.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}, :name => t('last_week')}
    older = {:contents => contents.select{|x| x.updated_at < Date.today - 7}, :name => t('older')}

    intervals = [today, yesterday, last_week, older]
  end

  def path_for_home(p={})
    per_page = p[:per_page].present? ? p[:per_page] : params[:per_page]
    contents = (params[:contents].present? ? params[:contents].split(",") : Space.contents.map(&:to_s)) + [p[:add_content]] -[p[:rm_content]]

    url_for(:per_page => per_page, :contents => contents.join(","))
  end

  def home_menu_checkbox(name)
    check_box_tag name, name , @contents.map(&:to_s).include?(name), :class => 'home_menu_checkbox'
  end

end
