class Users::RegistrationsController < Devise::RegistrationsController
  def new
    build_resource({})
    respond_with self.resource
    @reserve_code = ""
    @show = Show.new
    if params[:reserve_code]
      @reserve_code = params[:reserve_code]
    end

    if params[:show]
      @show = params[:show]
    end
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :provider, :facebook_url, :uid, :nickname, :location, :image)
  end
  private :resource_params
end