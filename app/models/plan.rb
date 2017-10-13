# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Plan < ActiveRecord::Base

  has_many :subscriptions

  validates :name, :presence => true
  validates :identifier, :presence => true
  validates :ops_type, :presence => true
  validates :currency, :presence => true
  validates :interval, :presence => true
  validates :interval_type, :presence => true
  has_many :subscription, dependent: :destroy

  before_create :create_ops_plan
  before_destroy :delete_ops_plan

  def self.free_plan
    params = {
      name: "Free Plan",
      identifier: "free_plan",
      ops_type: nil,
      currency: "BRL",
      interval_type: "months",
      interval: 1 }
    Plan.new(params)
  end

  def free?
    self.ops_id == "Free Plan"
  end

  def create_ops_plan
    if ops_type == "IUGU"
      self.ops_id = Mconf::Iugu.create_plan(self.name, self.identifier, self.currency, self.interval, self.interval_type, self.ops_id)

      if self.ops_id == nil
        logger.error "No Token returned from IUGU, aborting"
        errors.add(:attr, "No Token returned from IUGU, aborting")
        raise ActiveRecord::Rollback
      end

    else
      logger.error "Bad ops_type, can't create plan"
      errors.add(:attr, "Bad ops_type, can't create plan")
      raise ActiveRecord::Rollback
    end
  end

  def self.import_ops_plan
    Mconf::Iugu.fetch_all_plans.each do |plan|
      params = { 
                 name: plan.attributes["name"], 
                 identifier: plan.attributes["identifier"], 
                 ops_type: 'IUGU',
                 ops_id: plan.attributes["id"],
                 currency: plan.attributes["prices"].first["currency"], 
                 interval_type: plan.attributes["interval_type"], 
                 interval: plan.attributes["interval"] }
      
      Plan.find_by_ops_id(params[:ops_id]).present? ? puts("Plan already imported") : Plan.create(params)
    end
  end

  def delete_ops_plan
    if ops_type == "IUGU"
      plan = Mconf::Iugu.destroy_plan(self.ops_id)

      if plan == false
        logger.error "Could not delete plan from OPS, aborting"
        errors.add(:attr, "Could not delete plan from OPS, aborting")
        raise ActiveRecord::Rollback
      end

    else
      logger.error "Bad ops_type, can't delete plan"
      errors.add(:attr, "Bad ops_type, can't delete plan")
      raise ActiveRecord::Rollback
    end
  end

  def self.get_plans_from_ops
    plans = Mconf::Iugu.fetch_all_plans
    puts plans
  end

end
