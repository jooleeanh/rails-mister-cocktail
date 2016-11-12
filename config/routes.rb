Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"
  root 'cocktails#index'
  post 'cocktails/sample' => 'cocktails#sample', as: :sample_cocktails
  resources :cocktails, only: [:index, :show, :new, :create, :edit, :update] do
    resources :doses, only: [:index, :new, :create, :destroy], shallow: true
  end
end
