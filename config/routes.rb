Dwollotron::Application.routes.draw do
  resources :accounts do
    member do
      post 'queue'
      post 'cancel_current_payment'
    end
  end
  resources :payments, only: [:show]
  root to: redirect("/accounts")
end
