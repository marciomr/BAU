# coding: utf-8

class BackupsController < ApplicationController
  
  def index
    @user = User.find_by_username(params[:user_id]) if params[:user_id]
    @backups = Backup.find_by_username(@user.username)
  end
  
  def create
#    @xml =  render_to_string :xml => @user.books, :except  => [:user_id, :id, :created_at, :updated_at, :delta], :include => {:authors => {:only => [:name]}, :tags => {:only => [:title]}}

    call_rake(:backup, :create, :username => params[:user_id])
    redirect_to :back, :notice => 'Criando backup. Aguarde alguns minutos e retorne a essa página.'
  end
  
  def recover
    call_rake(:backup, :recover, :id => params[:id], :username => params[:user_id])    
    redirect_to :back, :notice => "Recuperando arquivo #{params[:id]}. Isso pode demorar."
  end

  def download
    send_file("#{Backup.folder(params[:user_id])}/#{params[:id]}.xml", :type => 'application/xml')
  end

  def upload
    upload = params[:upload]

    name =  upload['datafile'].original_filename
    
    # verificar se o arquivo eh um xml valido    
    path = File.join(Backup.folder(params[:user_id]), name)
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    redirect_to :back, :notice => "Arquivo salvo com sucesso."
  end
end
