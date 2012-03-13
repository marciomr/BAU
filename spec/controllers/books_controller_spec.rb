require File.dirname(__FILE__) + '/../spec_helper'

describe BooksController do
#  fixtures :all
#  render_views

#  it "index action should render index template" do
#    get :index
#    response.should render_template(:index)
#  end

#  it "index action should respond to rss" do
#    get :index, :format => 'rss'
#    response.should render_template(:index)
#  end

#  it "adv_search action should render adv_search partial template" do
#    get :adv_search
#    response.should render_template(:partial => '_adv_search')
#  end

#  it "show action should render show template" do
#    get :show, :id => Book.first
#    response.should render_template(:show)
#  end

#  it "new action should render new template" do
#    get :new
#    response.should render_template(:new)
#  end

#  it "create action should render new template when model is invalid" do
#    Book.any_instance.stubs(:valid?).returns(false)
#    post :create
#    response.should render_template(:new, :book => Book.first, :params => {})
#  end

#  it "create action should redirect when model is valid" do
#    Book.any_instance.stubs(:valid?).returns(true)
#    post :create
#    flash[:notice].should_not be_nil
#    response.should redirect_to(book_url(assigns[:book]))
#  end

#  it "create action should pass params to book" do
#    Book.any_instance.stubs(:valid?).returns(true)
#    post :create, :book => { :title => 'Title' }
#    assigns[:book].title.should == 'Title'
#  end

#  it "edit action should render edit template" do
#    get :edit, :id => Book.first
#    response.should render_template(:edit, :book => Book.first)
#  end

#  it "update action should render edit template when model is invalid" do
#    Book.any_instance.stubs(:valid?).returns(false)
#    put :update, :id => Book.first
#    response.should render_template(:edit, :book => Book.first)
#  end

#  it "update action should redirect when model is valid" do
#    Book.any_instance.stubs(:valid?).returns(true)
#    put :update, :id => Book.first
#    response.should redirect_to(book_url(assigns[:book]))
#  end

#  it "update action should pass params to book" do
#    Book.any_instance.stubs(:valid?).returns(true)
#    post :update, :id => Book.first, :book => { :title => 'Title' }
#    assigns[:book].title.should == 'Title'
#  end

#  it "destroy action should destroy model and redirect to index action" do
#    book = Book.first
#    delete :destroy, :id => book
#    response.should redirect_to(books_url)
#    flash[:notice].should_not be_nil
#    Book.exists?(book.id).should be_false
#  end
end
