RobotKarel::Application.routes.draw do
  resources :actors
  resources :simulations
  resources :maps

  match 'maps/:id/get_map' => 'maps#get_map'
  match 'maps/:id/save_map' => 'maps#save_map'
  match 'simulations/:simulation_id/get_map' => 'simulations#get_map'
  match 'simulations/:id/place_actors' => 'simulation#place_actors'
  match 'simulations/:id/save_sim' => 'simulations#save_sim'
  match 'simulations/:id/:count/simulate' => 'simulations#simulate'
  match 'simulations/:id/get_story' => 'simulations#get_story'
  match 'simulations/:id/watch' => 'simulations#watch'
  match 'simulations/:id/get_initial_state' => 'simulations#get_initial_state'
  match 'simulations/:id/get_actors' => 'simulations#get_actors'
  match 'actors/:id/get_properties' => 'actors#get_properties'

  # match 'test/lol' => 'test#lol'
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
  match '/' => 'help#welcome'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
