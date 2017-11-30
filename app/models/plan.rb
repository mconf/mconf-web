# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Plan < ActiveRecord::Base

  has_many :subscriptions, primary_key: "ops_token", foreign_key: "plan_token", dependent: :restrict_with_exception

  validates :name, :presence => true
  validates :identifier, :presence => true
  validates :ops_type, :presence => true
  validates :currency, :presence => true
  validates :interval, :presence => true
  validates :interval_type, :presence => true

  before_create :create_ops_plan
  before_destroy :delete_ops_plan

  OPS_TYPES = { iugu: "IUGU" }

  def self.free_plan
    params = {
      name: "Free Plan",
      identifier: "free_plan",
      ops_type: nil,
      currency: "BRL",
      interval_type: "months",
      interval: 1
    }
    Plan.new(params)
  end

  def free?
    self.ops_token == "Free Plan"
  end

  def create_ops_plan
    if ops_type == Plan::OPS_TYPES[:iugu]
      unless self.ops_token.present?
        self.ops_token = Mconf::Iugu.create_plan(self.name, self.identifier, self.currency, self.interval, self.interval_type)

        if self.ops_token == nil
          logger.error I18n.t('.plan.errors.no_token')
          errors.add(:ops_error, I18n.t('.plan.errors.no_token'))
          raise ActiveRecord::Rollback
        end
      end
    else
      logger.error I18n.t('.plan.errors.ops_type_create_plan')
      errors.add(:ops_error, I18n.t('.plan.errors.ops_type_create_plan'))
      raise ActiveRecord::Rollback
    end
  end

  def self.import_ops_plan
    plans = Mconf::Iugu.fetch_all_plans
    if plans.present?
      plans.each do |plan|
        params = {
          name: plan.attributes["name"],
          identifier: plan.attributes["identifier"],
          ops_type: 'IUGU',
          ops_token: plan.attributes["id"],
          currency: plan.attributes["prices"].first["currency"],
          interval_type: plan.attributes["interval_type"],
          interval: plan.attributes["interval"]
        }

        Plan.find_by(ops_token: params[:ops_token]).present? ? logger.info(I18n.t('.plan.info')) : Plan.create(params)
      end
    end
  end

  def delete_ops_plan
    if ops_type == Plan::OPS_TYPES[:iugu]
      plan = Mconf::Iugu.destroy_plan(self.ops_token)

      if plan == false
        logger.error I18n.t('.plan.errors.delete')
        errors.add(:ops_error, I18n.t('.plan.errors.delete'))
        raise ActiveRecord::Rollback
      end

    else
      logger.error I18n.t('.plan.errors.ops_type_delete_plan')
      errors.add(:ops_error, I18n.t('.plan.errors.ops_type_delete_plan'))
      raise ActiveRecord::Rollback
    end
  end

  def self.get_plans_from_ops
    plans = Mconf::Iugu.fetch_all_plans
    puts plans
  end

end
