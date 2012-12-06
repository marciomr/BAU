require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe "routing" do
      it '/signup to User#new as signup' do
        path = signup_path
        path.should == '/signup'
        { :get => path }.should route_to(
          :controller => 'users',
          :action => 'new'
        )
      end

      it '/:user_id/profile to User#show as user' do
        user = create(:user, :username => 'foo_bar')
        path = user_path(user) 
        path.should == "/#{user.username}/profile"
        { :get => path }.should route_to(
          :controller => 'users',
          :action => 'show',
          :id => user.username
        )
      end

      it '/:user_id/edit to User#edit as edit_user' do
        user = create(:user, :username => 'foo_bar')
        path = edit_user_path(user) 
        path.should == "/#{user.username}/edit"
        { :get => path }.should route_to(
          :controller => 'users',
          :action => 'edit',
          :id => user.username
        )
      end
    
      it '/users to User#index as users' do
        path = users_path 
        path.should == "/users"
        { :get => path }.should route_to(
          :controller => 'users',
          :action => 'index',
        )
      end
  
  end
end
