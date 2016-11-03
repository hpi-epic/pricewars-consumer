Rails.application.routes.draw do
  post "setting", to: "setting#create"
  delete "setting", to: "setting#delete"

  get "behavior", to: "behavior#index"
end
