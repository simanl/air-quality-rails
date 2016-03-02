class AdminController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout "admin"

  before_action :authenticate_user!
  before_action :authorize_admin_user!

  def authorize_admin_user!
    fail "Forbidden" unless current_user.administrator?
  end
end
