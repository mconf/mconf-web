module HomesHelper
  def intervals(contents)
    today = {:contents => contents.select{|x| x.updated_at > Date.yesterday}, :name => t('today')}
    yesterday = {:contents => contents.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}, :name => t('yesterday')}
    last_week = {:contents => contents.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}, :name => t('last_week')}
    older = {:contents => contents.select{|x| x.updated_at < Date.today - 7}, :name => t('older')}
  
    intervals = [today, yesterday, last_week, older]
  end
end