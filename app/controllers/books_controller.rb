# coding: utf-8

class BooksController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]
  
  %w(editor subject city country).each do |field| 
    define_method "typeahead_#{field}" do
      @books = Book.order(field.to_sym).where("#{field} like ?", "%#{params[:query]}%")
      render :json => @books.map(&(field.to_sym)).uniq
    end
  end  
  
  # autocomplete para autores
  def typeahead_authors  
    @authors = Author.order(:name).where("name like ?", "%#{params[:query]}%")
    render :json => @authors.map(&:name).uniq
  end

  # autocomplete para tags
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
      
      format.xml do 
        if params[:user_id]
          @user = User.find_by_username(params[:user_id])
          render :xml => @user.books, :except => [:user_id, :id, :created_at, :updated_at], 
                                      :include => {:authors => {:only => [:name]}, :tags => {:only => [:title]}}
        else
          render :xml => @books, :except => [:user_id, :id, :created_at, :updated_at], 
                                 :include => {:authors => {:only => [:name]}, :tags => {:only => [:title]}}
        end
      end
    end
  end

  def show
    @user = User.find_by_username(params[:user_id])
    @book = @user.books.find_by_tombo(params[:id])
    
    # se o livro não for encontrado 404
    raise ActionController::RoutingError.new('Not Found')if @book.nil?
  end

  def new
    @user = User.find_by_username(params[:user_id])

    # tem que estar no site de alguma biblio para criar livro
    if @user.nil? || @user.admin?
      redirect_to root_path, :alert => "Você precisa estar no site de um biblioteca para criar um livro." 
    
    # guest não pode criar livros
    elsif guest? 
      unautorized!
            
    # só o admin pode criar na conta de outro usuário
    elsif @user != current_user && !admin?
      unautorized!(new_user_book_path(current_user))
    
    elsif params[:isbn]
      # tenta preencher os campos automaticamente
      @attributes = Book.get_attributes(params[:isbn]) || { 'isbn' => params[:isbn] } 
      @book = Book.new @attributes
    else
      @book = Book.new
      # um campo de autor aparece sem precisar clicar em "adicionar autor"
      @book.authors.build 
    end 
  end

  def create    
    @book = Book.new(params[:book])
    @user = User.find_by_username(params[:user_id])
    
    access_restricted_to([@user, admin]) do    
      @book.user_id = @user.try(:id)
    
      if @book.save
        redirect_to [@user, @book], :notice => "Livro criado com sucesso."
      else
        render :new
      end
    end
  end

  def edit
    @user = User.find_by_username(params[:user_id])
    @book = @user.books.find_by_tombo(params[:id])

    access_restricted_to([@user, admin])
  end

  def update    
    @book = Book.find(params[:id])
    @user = User.find_by_username(params[:user_id])
    
    access_restricted_to([@user, admin]) do
      if @book.update_attributes(params[:book])
        redirect_to [@book.user, @book], :notice  => "Livro editado com sucesso."
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @user = User.find_by_username(params[:user_id])
    @book = @user.books.find_by_tombo(params[:id])
    
    access_restricted_to([@user, admin]) do
      @book.destroy
      redirect_to user_books_path(@user), :notice => "Livro deletado com sucesso."
    end
  end
end
