Rails.application.routes.draw do
  post "register", to: "register#create"

  get "setting/sample", to: "setting#sample"
  post "setting", to: "setting#create"
  put "setting", to: "setting#create"
  delete "setting", to: "setting#delete"

  get "behavior", to: "behavior#index"
end
