Rails.application.routes.draw do
  root 'cocktails#index'
  resources :cocktails, only: [:index, :show, :new, :create] do
    resources :doses, only: [:index, :new, :create, :destroy], shallow: true
  end
end
