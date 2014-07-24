class RecentActivity < PublicActivity::Activity
  attr_accessible :notified
  self.per_page = 10
end
