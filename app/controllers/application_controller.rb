class ApplicationController < ActionController::Base
  helper_method :current_user, :admin?, :unauthorized!
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5f2f9061bb334aa869d4717f2779655e'

  protected
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def admin
    User.find(1)
  end 

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] = request.url
    redirect_to login_path, :alert => "Acesso negado!"
  end   

end
