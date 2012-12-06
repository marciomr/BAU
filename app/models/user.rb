# coding: utf-8

class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username
  attr_accessible :username, :description, :name, :password, :password_confirmation

  has_secure_password
  has_many :books
  
  validates_presence_of :name, :on => :create, :message => "O usuário deve ter um nome."
  validates :password, :length => { :minimum => 6, :too_short => "A senha precisa ter pelo menos %{count} letras" }, :on => :create
  validates :password, :length => { :minimum => 6, :too_short => "A senha precisa ter pelo menos %{count} letras" }, :on => :update, :allow_blank => true 
  validates_uniqueness_of :username, :name, :message => "Já existe usuário com este nome."
  validates_format_of :username, :with => /^[\w\d_]+$/, :message => "Formato inválido para nome do Usuário."
  validates_exclusion_of :username, :in => %w(users books new edit signup login logout), :message => "Nome reservado."

  before_save do 
    if !admin?
      path = "#{Backup.folder(username)}"
      Dir::mkdir(path) if !FileTest::directory?(path)
    end
  end
  
  def admin?
    id == 1
  end
  
  def last_tombo
    books.empty? ? 0 : books.map{ |b| b.tombo.to_i }.sort.last
  end
  
  def self.names
    (all.drop(1)).map{ |b| [b.name, b.username] }
  end
end
