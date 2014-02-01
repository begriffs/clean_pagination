class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CleanPagination

  def index
    paginate total_items, 100 do |limit, offset|
      render json: [offset .. offset+limit]
    end
  end

  def total_items
    raise 'stub it for now'
  end
end
