class ApplicationController < ActionController::Base
  respond_to :html, :json
  protect_from_forgery with: :null_session
  before_filter :configure_permitted_parameters, if: :devise_controller?
  # check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :provider, :facebook_url, :facebook_uid, :facebook_nickname, :facebook_email, :facebook_image, :facebook_location, :facebook_url, :stripe_id, :stripe_scope, :stripe_livemode, :stripe_publishable_key, :stripe_token, :stripe_token_type, :stripe_recipient_id, :stripe_recipient_email, :stripe_access_key, :uid, :nickname, :location, :image, :email_subscribe) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me, :email_subscribe) }
  end
end