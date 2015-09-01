class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include JsonApiHelper
  rescue_from ActiveRecord::AssociationNotFoundError,
    with: :json_api_association_not_found

end
