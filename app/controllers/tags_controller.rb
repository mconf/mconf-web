class TagsController < InheritedResources::Base

  include Mconf::SelectControllerModule # select
  respond_to :json, only: :select

end