# coding: utf-8

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to (session[:return_to] || root_url), :notice => "Logado!"
      session[:return_to] = nil
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
