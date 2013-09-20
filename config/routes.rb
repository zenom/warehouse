Warehouse::Application.routes.draw do
  get "transcode/monitor"

  devise_for :user
  #match "/:id" => "history#details", :as => "details"
  resources :folders
  resources :history do
    match "process" => "history#re_process_video"
    match "cancel" => "history#cancel_processing"
    match "archive" => "history#archive"
    match "clear_failed" => "history#clear_failed"
    match "update_status" => "history#update_status"
    match "details" => "history#details"
  end
  
  match "/completed/search", :to => "history#search_completed"
  match "/archived/search", :to => "history#search_archived"
  match "completed" => "history#load_completed"
  match "pending" => "history#load_pending"
  match "failures" => "history#load_failures"
  match "processing" => "history#load_processing"
  match "archived" => "history#load_archived"
  match "cancelled" => "history#load_cancelled"
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  root :to => "history#index"
end
