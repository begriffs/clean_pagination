class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CleanPagination

  def index
    paginate total_items, max_range do |limit, offset|
      action limit, offset
      render json: [limit, offset], status: index_status
    end
  end

  def total_items
    raise 'stub me'
  end

  def max_range
    raise 'stub me'
  end

  def action limit, offset
    # gets spied on
  end

  def index_status
    200
  end
end
