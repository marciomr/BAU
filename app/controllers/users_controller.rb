# coding: utf-8

class UsersController < ApplicationController
  
  def index
    access_restricted_to(admin) do
      @users = User.all - [admin]
    end
  end
  
  def new
    access_restricted_to(admin) do
      @user = User.new
    end
  end
  
  def create
    access_restricted_to(admin) do
      @user = User.new(params[:user])
      if @user.save
        redirect_to root_url, :notice => "Usuário criado com sucesso."
      else
        render "new"
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])

    access_restricted_to([@user, admin])
  end
  
  def update
    @user = User.find(params[:id])
    
    access_restricted_to([@user, admin]) do
      if @user.update_attributes(params[:user])
        redirect_to @user, :notice  => "Usuário atualizado com sucesso."
      else
        render :action => 'edit'
      end
    end
  end
  
  def show
     @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
   
    access_restricted_to([@user, admin]) do
      @user.destroy
      redirect_to users_url, :notice => "Usuário removido com sucesso."
    end
  end

end
