Rails.application.routes.draw do
  post "register", to: "register#create"

  get "setting/sample", to: "setting#index"
  get "setting", to: "setting#index"
  post "setting", to: "setting#create"
  put "setting", to: "setting#update"
  delete "setting", to: "setting#delete"

  post "setting/products", to: "setting#update_product_details"

  get "behavior", to: "behavior#index"

  get "status", to: "setting#status"
end
