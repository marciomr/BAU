class BooksController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]
  before_filter :authorize, :except => [:index, :show, :root]
  
  autocomplete :author, :name
  autocomplete :tag, :title
  for attribute in [:editor, :subject, :collection, :city, :country] do
    autocomplete :book, attribute
  end
    
  def gbook  
    @params = Book.gbook(params[:isbn])
    @isbn = params[:isbn]
    @book = Book.find(params[:book_id]) if params[:book_id]
    @book.authors = [] unless @book.nil?
  end  
  
  def index
    respond_to do |format|
      format.html do
        @books = Book.search params[:search], 
                  :star => true,       # Automatic Wildcard
                  :field_weights => {  # Order of relevance
                    :author => 20, 
                    :title => 10, 
                    :tag => 5, 
                    :subject => 5, 
                    :description => 1
                    },
                  :page => params[:page], 
                  :per_page => APP_CONFIG['per_page']
        
        @books.order_by_relevance_title          
       
        @books.by_title(params['title_filter']) if !params['title_filter'].blank? 
        @books.by_author(params['author_filter']) if !params['author_filter'].blank?
        @books.by_author(params['editor_filter']) if !params['editor_filter'].blank?
        @books.by_language(params['language_filter']) if !params['language_filter'].blank?
        @books.by_collection(params['collection_filter']) if !params['collection_filter'].blank?
                
        @books.with_pdflink if params['pdf_filter']
        
        @total ||= @books.total_entries
      end
      format.rss do             
        @books = Book.all
      end
    end
    
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
    @book.authors.build
  end

  def create
    @book = Book.new(params[:book])
    @book.tombo = Book.last_tombo + 1
    if @book.save
      redirect_to @book, :notice => "Successfully created book."
    else
      render :action => 'new'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      redirect_to @book, :notice  => "Successfully updated book."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_url, :notice => "Successfully destroyed book."
  end
end
