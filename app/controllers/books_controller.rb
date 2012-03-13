# coding: utf-8

class BooksController < ApplicationController
  load_and_authorize_resource
  protect_from_forgery :only => [:create, :update, :destroy]
  
  autocomplete :author, :name
  autocomplete :tag, :title
  for attribute in [:editor, :subject, :collection, :city, :country] do
    autocomplete :book, attribute
  end

  def adv_search
    render :partial => 'adv_search', :layout => false  
  end

  def index
    respond_to do |format|
      
      format.html do
        @adv_search = !params[:adv_search].nil?
         
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
  end

  def new
    @user = User.find_by_username(params[:user_id])
    if (@user.try(:admin?))
      redirect_to root_path, :alert => "O admin não pode possuir livros." 
    else
      @attributes = {}
      @attributes = Book.get_attributes(params[:isbn]) if params[:isbn]
      @book = Book.new
      @book.authors.build
    end
  end

  def create    
    @book = Book.new(params[:book])
    user = User.find_by_username(params[:user_id])
    @book.user_id = user.try(:id)
    
    if @book.save
      redirect_to user_book_path(user, @book), :notice => "Livro criado com sucesso."
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
    redirect_to books_url, :notice => "Livro deletado com sucesso."
  end
end
