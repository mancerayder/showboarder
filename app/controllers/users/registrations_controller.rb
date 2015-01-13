class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, :only => [:create]
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
    reserve_code = ""
    resource_saved = resource.save
    AdminMailer.delay.new_user(resource.id)
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        if params[:user][:reserve_code] && params[:user][:reserve_code] != ""
          reserve_code = params[:user][:reserve_code]
          resource.tickets_reserved_assign(reserve_code)

          if resource.tickets && resource.tickets.count > 0
            ticket = resource.tickets.first
            redirect_to board_show_checkout_path(ticket.show.board, ticket.show)
          else
            redirect_to root_path # just in case something went wrong.  TODO - double check if this case is hit if a ticket expires
          end
        elsif params[:path_from] && params[:path_from] == "create_board"
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
    params.require(:user).permit(:name, :reserve_code, :email, :password, :password_confirmation, :provider, :facebook_url, :path_from, :uid, :nickname, :location, :image, :email_subscribe)
  end
  private :resource_params
end