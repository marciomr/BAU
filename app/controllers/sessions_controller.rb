class SessionsController < ApplicationController
  def new
  end

  def create
    if Session.logon(params[:password])
      flash[:notice] = "Successfully logged in" 
      session[:admin] = true
      redirect_to (session[:return_to] || root_path)
    else
      flash[:error] = "Login failed."
      render :action => :new
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Successfully logged out"
    redirect_to (session[:return_to] || :controller => 'books', :action => 'index')
  end

end
