Rails.application.routes.draw do
  post "register", to: "register#create"

  post "setting", to: "setting#create"
  delete "setting", to: "setting#delete"

  get "behavior", to: "behavior#index"
end
