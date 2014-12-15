class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @reserve_code = ""
    @path_from = ""
    if params[:reserve_code]
      @reserve_code = params[:reserve_code]
    end

    if params[:path_from] && params[:path_from] == "create_board"
      @path_from = "create_board"
    end

    build_resource({})
    respond_with self.resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      resource.tickets_reserved_assign
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        if params[:path_from] && params[:path_from] == "create_board"
          respond_with resource, location: new_board_path
        else
          respond_with resource, location: after_sign_up_path_for(resource)
        end
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
    params.require(:user).permit(:name, :reserve_code, :email, :password, :password_confirmation, :provider, :facebook_url, :path_from, :uid, :nickname, :location, :image)
  end
  private :resource_params
end