# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

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
      session[:return_to] = request.request_uri
      flash[:error] = "Unauthorized access"  
      redirect_to :controller => 'sessions', :action => 'new'
      false  
    end  
  end
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
