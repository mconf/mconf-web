# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantConfirmation < ActiveRecord::Base
  belongs_to :participant, dependent: :destroy, class_name: "MwebEvents::Participant"
  before_create :generate_token

  delegate :email, to: :participant, allow_nil: true

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end

  def to_param
    token
  end

  def confirm!
    update_attributes confirmed_at: Time.now
  end

  def confirmed?
    confirmed_at.present?
  end
end
