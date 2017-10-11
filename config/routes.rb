class DomainConstraint
  def initialize(domain)
    @domains = [domain].flatten
  end

  def matches?(request)
    @domains.include? request.domain
  end
end



Rails.application.routes.draw do

  resources :code_puzzle_classes do
    resources :code_puzzle_projects do
      resources :code_puzzle_groups do
        resources :code_puzzle_cards
      end
    end
  end

  get 'codepuzzle/:id', to: 'code_puzzle_classes/#show'
  get 'codepuzzle/:class_id/projects/:id', to: 'code_puzzle_projects/#show'

  resources :subscribers, only: [:create]

  resources :programs, only: [:index, :show]
  resources :technologies, only: [:index, :show]

  get 'learn_more' => 'welcome#learn_more', as: :learn_more
  get 'advisors' => 'welcome#advisors', as: :advisors
  get 'day_in_the_life' => 'welcome#day_in_the_life', as: :day_life
  get 'contact' => 'welcome#contact', as: :contact

  constraints DomainConstraint.new('thecodepuzzle.com') do
    root :to => 'code_puzzle_classes#index'
  end

  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
