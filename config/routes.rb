BAU::Application.routes.draw do

  resources :books, :only => [:index] do
    %w(editor subject city country authors tags title).each do |field|
      get "typeahead_#{field}", :on => :collection
    end  
    
    get :adv_search, :on => :collection
  end


  resources :sessions, :only => [:create]
  
  match 'login' => 'sessions#new'
  match 'logout' => 'sessions#destroy'  

  match ':id/profile' => 'users#show', :as => :user
  match 'users' => 'users#index', :as => :users  
  match 'signup' => 'users#new'

  root :to => "books#index", :via => :get  
  
  resources :users, :path => '', :except => [:show, :index, :new]
  resources :users, :path => '', :only => [] do
    resources :backups, :only => [:index, :create] do
      post :recover, :on => :member
      post :upload, :on => :collection
      get :download, :on => :member
    end 
    resources :books, :path => ''
  end
    
end
