class SessionsController < ApplicationController
  def new
  end

  def create
    if Session.logon(params[:password])
      flash[:notice] = "Logado com sucesso." 
      session[:admin] = true
      redirect_to (session[:return_to] || root_path)
    else
      flash[:error] = "Login falhou."
      render :action => :new
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Deslogado com sucesso."
    redirect_to(session[:return_to] || root_path)
  end

end
