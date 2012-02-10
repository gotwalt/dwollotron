Dwollotron::Application.routes.draw do
  resources :accounts, :only => [:index, :show]
  resources :payments, :only => [:show]
  root :to => 'accounts#index'
end
