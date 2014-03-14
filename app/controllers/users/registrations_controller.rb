class Users::RegistrationsController < Devise::RegistrationsController
  def resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :facebook_url, :uid, :nickname, :location, :image)
  end
  private :resource_params
end