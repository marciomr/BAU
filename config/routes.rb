Terralivre::Application.routes.draw do

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
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
