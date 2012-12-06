require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  describe "routing" do
    it '/login to Session#new as login' do
      path = login_path
      path.should == '/login'
      { :get => path }.should route_to(
        :controller => 'sessions',
        :action => 'new'
      )
    end

    it '/logout to Session#destroy as logout' do
      path = logout_path 
      path.should == "/logout"
      { :get => path }.should route_to(
        :controller => 'sessions',
        :action => 'destroy'
      )
    end
  end
end
