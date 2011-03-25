class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :admin?    
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5f2f9061bb334aa869d4717f2779655e'

  protected
  
  def admin?
    session[:admin]
  end
  
  def authorize
    unless admin?
      session[:return_to] = request.url
      flash[:error] = "Acesso negado"  
      redirect_to login_path
      false  
    end  
  end
end
