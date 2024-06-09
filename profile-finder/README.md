# Steps

- rails new profile-finder --database=postgresql
- bundle add cssbundling-rails
- rails css:install:bootstrap
  To add bootstrap and popper.js into importmap.rb
- ./bin/importmap pin bootstrap
- rails g controller home index
- In routes.rb, replace get 'home/index' with root 'home#index'
- rails g resource User name email city state country phone
