class TagsController < InheritedResources::Base

  include Mconf::SelectControllerModule # select
  respond_to :json, only: :select

  before_filter :authenticate_user!

end
