class JoinRequestsController < ApplicationController
  def create
    @join_request = group.join_requests.build params[:join_request]
    @join_request.candidate = current_agent

    respond_to do |format|
      if @join_request.save
        format.html {
          flash[:notice] = t('join_request.created')
          redirect_to(root_path)
        }
      else
        flash[:error] = @join_requests.errors.to_xml
        redirect_to request.referer
      end
    end
  end

  def update
    join_request.attributes = params[:join_request]
    join_request.introducer = current_agent if join_request.recently_processed?

    respond_to do |format|
      if join_request.save
        format.html {
          flash[:notice] = ( join_request.recently_processed? ?
                            ( join_request.accepted? ? t('join_request.accepted') : t('join_request.discarded') ) :
                            t('join_request.updated'))
          redirect_to request.referer
        }
      else
        format.html {
          flash[:error] = @join_request.errors.to_xml
          redirect_to request.referer
        }
      end
    end
  end

  private

  def join_request
    @join_request ||= group.join_requests.find(params[:id])
  end

  def group
    @group ||= record_from_path(:acts_as => :stage)
  end
end
