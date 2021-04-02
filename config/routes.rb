Rails.application.routes.draw do
  resources :exercises
  devise_for :users, controllers: {sessions: "sessions"}


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # scope admin
  get '/admin/dashboard', to: 'admin#dashboard'
  get '/admin/index', to: 'admin#index'
  get '/admin/my_profile', to: 'admin#my_profile'

  # admin, superadmin only
  get '/admin/logopedisten', to: 'admin#logopedisten'
  get '/admin/logs', to: 'admin#logs'

  # users
  namespace :admin do
    resources :users
    get 'users/:id/add_exercise/:ex_id', to: 'users#add_exercise'
    get 'users/:id/remove_exercise/:ex_id', to: 'users#remove_exercise'
    get 'clients', to: 'clients#index'
    get 'impersonate/(:id)' => 'users#impersonate', as: :impersonate
    get 'stop_impersonating' => 'users#stop_impersonating', as: :stop_impersonate
  end


  # for everyone
  get '/users/my_profile', to: 'users#my_profile'

  # scope?
  post '/app/new_login', to: 'app#new_login'
  get '/app/test_api', to: 'app#test_api'
  get '/app/login', to: 'app#login'
  get '/app/introductie', to: 'app#introductie'
  get '/app/info', to: 'app#info'
  get '/app/awards', to: 'app#awards'
  get '/app/oefening/:id', to: 'app#oefening'
  get '/app/oefeningen', to: 'app#oefeningen'
  get '/app/my_profile', to: 'app#my_profile'
  get '/app', to: 'app#index'

  # scope site
  get '/site/index', to: 'site#index'
  get '/site/test', to: 'site#test'

  # aliasses
  get '/sign_up', to: redirect('/users/sign_up')
  get '/inschrijven', to: redirect('/users/sign_in')
  get '/inloggen', to: redirect('/users/sign_in')
  get '/login', to: redirect('/users/sign_in')

  # test
  get 'autologintest', to: 'app#autologintest'

  root to: 'application#index'
  # match '*all', controller: 'application', action: 'cors_preflight_check', via: [:options]

  # config/routes.rb
  resources :web_hits, :only=>[:create]
  match '*all', :controller => 'web_hits', :action => 'options', :constraints => {:method => 'OPTIONS'}, via: [:options]

end
