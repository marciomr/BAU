# coding: utf-8

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to session[:return_to] || :back, :notice => 'Logado!'
      session[:return_to] = nil
    else
      redirect_to :back, :alert => 'Senha ou usuário inválido!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to :back, :notice => "Deslogado!"
  end

end 
