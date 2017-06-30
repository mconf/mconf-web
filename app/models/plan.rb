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
  validates :item_price, :presence => true
  validates :base_price, :presence => true
  validates :max_users, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true

  before_create :create_ops_plan
  before_destroy :delete_ops_plan

  def self.free_plan
    params = {
      name: "Free Plan",
      identifier: "free_plan",
      ops_type: nil,
      currency: "BRL",
      interval_type: "months",
      interval: 1,
      item_price: 0,
      base_price: 0,
      max_users: 2
    }
    Plan.new params
  end

  def free?
    self.ops_id == "Free Plan"
  end

  def create_ops_plan
    if ops_type == "IUGU"
      #self.ops_id = Mconf::Iugu.create_plan(:name, :identifier, :currency, :interval, :interval_type, :item_price, :base_price, :max_users)
      #ERRO 1 if we do not get an ops_id, cancel creation
    else
      logger.error "Bad ops_type, can't create plan"
      #ERRO 2
    end
  end

  def delete_ops_plan
    if ops_type == "IUGU"
      #plan = Mconf::Iugu.destroy_plan(:ops_id)
    else
      logger.error "Bad ops_type, can't create plan"
      #ERRO 2
    end
  end

  def get_plans_from_ops
    #plans = Mconf::Iugu.fetch_all_plans
    #Then after that we will get an array of plan objects, got to check which ones are already on the DB and create the missing ones
  end

end
