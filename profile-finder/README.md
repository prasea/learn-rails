# Steps

- rails new profile-finder --database=postgresql
- bundle add cssbundling-rails
- rails css:install:bootstrap
  To add bootstrap and popper.js into importmap.rb
- ./bin/importmap pin bootstrap
- rails g controller home index
- In routes.rb, replace get 'home/index' with root 'home#index'
- rails g resource User name email city state country phone

- rails g stimulus user\*modal
  We'll use user_modal stimulus to popup bootstrap modal for new, edit and show actions
  Q. How we can send request to new action of users_controller in rails using turbo_stream?
  In index.html.erb of users_controller,
  Option 1: `<%= link_to "New user", new_user_path(format: :turbo_stream)%>`
  Option 2: `<%= link_to "New user", new_user_path, "data-controller": "user-modal"%>`
  The better syntax for Option 2 is,
  `<%= link_to "New user", new_user_path, data: {controller: "user-modal"}%>`
