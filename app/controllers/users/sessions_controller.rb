class Users::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    @reserve_code = ""
    if params[:reserve_code]
      @reserve_code = params[:reserve_code]
    end    
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    resource.update(reserve_code:params[:user][:reserve_code])
    resource.tickets_reserved_assign
    respond_with resource, location: after_sign_in_path_for(resource)
  end  
end