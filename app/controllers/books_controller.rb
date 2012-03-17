# coding: utf-8

class BooksController < ApplicationController
  load_and_authorize_resource
  protect_from_forgery :only => [:create, :update, :destroy]
  
    %w(editor subject city country).each do |field| 
    define_method "typeahead_#{field}" do
      @books = Book.order(field.to_sym).where("#{field} like ?", "%#{params[:query]}%")
      render :json => @books.map(&(field.to_sym)).uniq
    end
  end  
  
  def typeahead_authors  
    @authors = Author.order(:name).where("name like ?", "%#{params[:query]}%")
    render :json => @authors.map(&:name).uniq
  end

  def typeahead_tags  
    @tags = Tag.order(:title).where("title like ?", "%#{params[:query]}%")
    render :json => @tags.map(&:title).uniq
  end

  def adv_search
    render :partial => 'adv_search', :layout => false  
  end

  def index
    respond_to do |format|
      
      format.html do
        @adv_search = params[:adv_search] if params[:adv_search]
         
        if params[:book] && params[:user]
          user = User.find_by_username(params[:user])  
          @book = user.books.find_by_tombo(params[:book])
        end         
        @books = Book.search params[:search], 
                  :star => true,       # Automatic Wildcard
                  :field_weights => {  # Order of relevance
                    :author => 20, 
                    :title => 10, 
                    :tag => 5, 
                    :subject => 5, 
                    :description => 1
                    },
                  :include => :authors,
                  :include => :tags,
                  :page => params[:page], 
                  :per_page => APP_CONFIG['per_page']
        
        @books.order_by_relevance_title          
   
        # scopes    
        ['title', 'author', 'editor'].each do |field|
          if !params["#{field}_filter"].blank? 
            @books.send("by_#{field}", params["#{field}_filter"]) 
          end
        end

        @books.by_language(params[:language_filter]) if params[:language_filter] && !params[:language_filter].first.blank?
        @books.with_pdflink if !params[:pdf_filter].blank?
        if params[:user_id]
          @user = User.find_by_username(params[:user_id])
          @books.with_user_id(@user.id) 
        end      
        @total = @books.total_entries
      end

      format.rss do 
        # maybe I should test this in views 
        @books = Book.search
        
        if params[:user_id]
          @user = User.find_by_username(params[:user_id])
          @books.with_user_id(@user.id) 
        end
      end
    end
  end

  def show
    @user = User.find_by_username(params[:user_id])
    @book = @user.books.find_by_tombo(params[:id])
    raise("not found") if @book.nil?
  end

  def new
    @user = User.find_by_username(params[:user_id])
    if @user != current_user
      redirect_to new_user_book_path(current_user), :alert => "Acesso Negado!" if !current_user.admin?
    end
    if @user.nil?
      redirect_to root_path, :alert => "Erro: você precisa estar no seu site para criar um livro." 
    else
      
      if params[:isbn]
        @attributes = Book.get_attributes(params[:isbn]) || { 'isbn' => params[:isbn] } 
        @book = Book.new @attributes
      else
        @book = Book.new
      end 

      @book.authors.build          
    end
  end

  def create    
    @book = Book.new(params[:book])
    @user = User.find_by_username(params[:user_id])
    @book.user_id = @user.try(:id)
    
    if @book.save
      redirect_to user_book_path(@user, @book), :notice => "Livro criado com sucesso."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find_by_username(params[:user_id])
  end

  def update    
    if @book.update_attributes(params[:book])
      redirect_to [@book.user, @book], :notice  => "Livro editado com sucesso."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @book.destroy
    redirect_to root_path, :notice => "Livro deletado com sucesso." # queria voltar pra onde eu estava...
  end
end
