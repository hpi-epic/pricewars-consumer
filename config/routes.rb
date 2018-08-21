Rails.application.routes.draw do
  post 'register', to: 'register#create'
  delete 'register', to: 'register#delete'

  get 'setting/sample', to: 'setting#index'
  get 'setting', to: 'setting#index'
  post 'setting', to: 'setting#create'
  put 'setting', to: 'setting#update'
  delete 'setting', to: 'setting#delete'

  get 'behavior', to: 'behavior#index'

  get 'status', to: 'setting#status'
end
