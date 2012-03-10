class BooksController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]
#  before_filter :authorize, :except => [:index, :show, :adv_search]
  
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
        ['title', 'author', 'editor', 'language', 'collection'].each do |field|
          if !params["#{field}_filter"].blank? 
            @books.send("by_#{field}", params["#{field}_filter"]) 
          end
        end
                
        @books.with_pdflink if params[:pdf_filter]
        @books.with_user_id(params[:user_id]) if params[:user_id]
        
        @total ||= @books.total_entries
      end

      format.rss do  
        if params[:user_id]
          @books = Book.search.with_user_id(params[:user_id]) 
        else
          @books = Book.all
        end
      end
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    if !current_user
      unauthorized!
    end
        
    @params = params[:isbn] ? Book.gbook(params[:isbn]) : {}
    @book = Book.new
    @book.authors.build      
  end

  def create
    if !current_user
      unauthorized!
    end
    
    @book = Book.new(params[:book])
    @book.user = current_user
    @book.tombo = current_user.books.last_tombo + 1
    if @book.save
      redirect_to @book, :notice => "Livro criado com sucesso."
    else
      render :action => 'new'
    end
  end

  def edit
    @book = Book.find(params[:id])
    if current_user != @book.user && !admin?
      unauthorized!
    end
  end

  def update    
    @book = Book.find(params[:id])
    if current_user != @book.user && !admin?
      unauthorized!
    elsif @book.update_attributes(params[:book])
      redirect_to @book, :notice  => "Livro editado com sucesso."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @book = Book.find(params[:id])
    if current_user != @book.user && !admin?
      unauthorized!
    else
      @book.destroy
      redirect_to books_url, :notice => "Livro deletado com sucesso."
    end
  end
end
