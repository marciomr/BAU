# coding: utf-8

class SessionsController < ApplicationController
  def new
  end

#  def create
#    if Session.logon(params[:password])
#      flash[:notice] = "Logado com sucesso." 
#      session[:admin] = true
#      redirect_to (session[:return_to] || root_path)
#    else
#      flash[:error] = "Login falhou."
#      render :action => :new
#    end
#  end

#  def destroy
#    reset_session
#    flash[:notice] = "Deslogado com sucesso."
#    redirect_to(session[:return_to] || root_path)
#  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logado!"
    else
      flash.now.alert = "Senha ou usuário invalido!"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Deslogado!"
  end

end
