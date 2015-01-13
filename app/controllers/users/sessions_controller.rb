class Users::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  # GET /resource/sign_in
  def new
    @reserve_code = ""
    if params[:reserve_code] && params[:reserve_code] != ""
      @reserve_code = params[:reserve_code]
    end    
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    @reserve_code = ""
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    if params[:user][:reserve_code] && params[:user][:reserve_code] != ""
      @reserve_code = params[:user][:reserve_code]
      if resource.tickets_reserved_assign(@reserve_code)
        ticket = resource.tickets.first
        respond_with resource, location: board_show_checkout_path(ticket.show.board, ticket.show)
      end
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end  
end