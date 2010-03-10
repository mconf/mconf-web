class LogosController < ApplicationController
  include ActionController::Logos

  before_filter :get_logoable_from_path
end
