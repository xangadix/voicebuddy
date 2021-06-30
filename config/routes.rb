Rails.application.routes.draw do

  resources :exercises
  delete 'remove_exercise/:id' => 'exercises#remove_exercise'

  devise_for :users, controllers: {sessions: "sessions"}


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # scope admin
  get '/admin/dashboard', to: 'admin#dashboard'
  get '/admin/index', to: 'admin#index'
  get '/admin/my_profile', to: 'admin#my_profile'

  # admin, superadmin only
  get '/admin/logopedisten', to: 'admin#logopedisten'
  get '/admin/logs', to: 'admin#logs'

  authenticated do
    get 'site/demo', to: 'site#demo'
  end

  # users
  namespace :admin do
    resources :users
    get 'users/:id/add_exercise/:ex_id', to: 'users#add_exercise'
    get 'users/:id/remove_exercise/:ex_id', to: 'users#remove_exercise'
    get 'clients', to: 'clients#index'
    get 'clients/new', to: 'clients#new'
    get 'clients/:id', to: 'clients#show'
    get 'impersonate/(:id)' => 'users#impersonate', as: :impersonate
    #get 'stop_impersonating' => 'users#stop_impersonating', as: :stop_impersonate
    post 'stop_impersonating' => 'users#stop_impersonating', as: :stop_impersonate
  end

  # for everyone
  get '/users/my_profile', to: 'users#my_profile'

  # scope?
  # get '/app/test_api', to: 'app#test_api'
  get '/app/login(/:login)', to: 'app#login'
  post '/app/new_login', to: 'app#new_login'
  get '/app/login_failed', to: 'app#login_failed'
  get '/app/forgot_password', to: 'app#forgot_password'

  get '/app/introductie(/:token)', to: 'app#introductie'
  get '/app/info(/:token)', to: 'app#info'
  get '/app/awards(/:token)', to: 'app#awards'
  get '/app/awards/claim/:id(/:token)', to: 'app#claim_reward'
  get '/app/claim_reward/:id(/:token)', to: 'app#claim_reward'
  get '/app/claim_streak/(:token)', to: 'app#claim_streak'
  get '/app/oefening/:id(/:token)', to: 'app#oefening'
  get '/app/oefeningen(/:token)', to: 'app#oefeningen'
  get '/app/my_profile(/:token)', to: 'app#my_profile'
  get '/app/update_exercise/:id/:token', to: 'exercises#update_exercise'
  get '/app(/:token)', to: 'app#index'

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
