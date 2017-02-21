## Repo Structure

```
|-- app
|   `-- controllers
|       |-- application_controller.rb
|       |-- behavior_controller.rb
|       |-- concerns
|       |-- register_controller.rb
|       `-- setting_controller.rb
|-- bin
|   |-- bundle
|   |-- rails
|   |-- rake
|   `-- setup
|-- Capfile
|-- config
|   |-- application.rb
|   |-- boot.rb
|   |-- database.yml
|   |-- deploy
|   |   `-- production.rb
|   |-- deploy_id_rsa_enc_travis
|   |-- deploy.rb
|   |-- environment.rb
|   |-- environments
|   |   |-- development.rb
|   |   |-- production.rb
|   |   `-- test.rb
|   |-- initializers
|   |   |-- assets.rb
|   |   |-- backtrace_silencers.rb
|   |   |-- cookies_serializer.rb
|   |   |-- filter_parameter_logging.rb
|   |   |-- inflections.rb
|   |   |-- mime_types.rb
|   |   |-- session_store.rb
|   |   `-- wrap_parameters.rb
|   |-- locales
|   |   `-- en.yml
|   |-- routes.rb
|   |-- secrets.yml
|   `-- unicorn.rb
|-- config.ru
|-- db
|   |-- development.sqlite3
|   |-- schema.rb
|   |-- seeds.rb
|   `-- test.sqlite3
|-- doc
|   |-- ApplicationController.html
|   |-- BehaviorController.html
|   |-- BuyingBehavior.html
|   |-- class_list.html
|   |-- css
|   |   |-- common.css
|   |   |-- full_list.css
|   |   `-- style.css
|   |-- Features.html
|   |-- file_list.html
|   |-- file.README.html
|   |-- frames.html
|   |-- index.html
|   |-- _index.html
|   |-- InvalidExpressionError.html
|   |-- js
|   |   |-- app.js
|   |   |-- full_list.js
|   |   `-- jquery.js
|   |-- LimitExceededError.html
|   |-- Logit.html
|   |-- method_list.html
|   |-- RandomGaussian.html
|   |-- RandomSigmoid.html
|   |-- RegisterController.html
|   |-- SettingController.html
|   `-- top-level-namespace.html
|-- Dockerfile
|-- Gemfile
|-- Gemfile.lock
|-- lib
|   |-- assets
|   |-- buyingbehavior.rb
|   |-- capistrano
|   |   `-- tasks
|   |-- features.rb
|   |-- gaussian.rb
|   |-- logit.rb
|   |-- sigmoid.rb
|   `-- tasks
|-- log
|   |-- development.log
|   `-- test.log
|-- public
|   |-- 404.html
|   |-- 422.html
|   |-- 500.html
|   |-- favicon.ico
|   `-- robots.txt
|-- Rakefile
|-- README.md
|-- spec
|   |-- controllers
|   |   |-- behavior_controller_spec.rb
|   |   |-- register_controller_spec.rb
|   |   `-- setting_controller_spec.rb
|   |-- rails_helper.rb
|   `-- spec_helper.rb
|-- tmp
|   |-- cache
|   |   `-- assets
|   |-- pids
|   |-- sessions
|   `-- sockets
`-- vendor
```

29 directories, 83 files
