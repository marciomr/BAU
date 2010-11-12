class BooksController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]
  before_filter :authorize, :except => [:index, :show]
  
  auto_complete_for :book, :editor
  auto_complete_for :book, :city
  auto_complete_for :book, :country
  auto_complete_for :book, :language
  auto_complete_for :book, :collection
  auto_complete_for :author, :name
          
  def index
    @books = Book.search params[:search], :field_weights => { :author => 20, :title => 10 }, :page => params[:page], :per_page => 12
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
    if @book.save
      flash[:notice] = "Successfully created book."
      redirect_to @book
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
      flash[:notice] = "Successfully updated book."
      redirect_to @book
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    flash[:notice] = "Successfully destroyed book."
    redirect_to books_url
  end
end
