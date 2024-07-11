# README
Building a developers community application in Rails 7.2


# Install Twitter Bootstrap and Add Header-Footer partials
Since we have `cssbundling-rails` gem. Run `rails css:install:bootstrap` 

Running this command will generate app/assets/builds/applications.css containing all bootstrap's CSS properties. Also stylesheets/application.css becomes stylesheets/application.bootstrap.scss

If it happens, Bootstrap is successfully installed in our project. Since bootstrap has dependency on popper js, we need to pin it, 

`./bin/importmap pin boostrap` command will add below two lines in config/importmap.rb 
pin "bootstrap" # @5.3.3
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8



# Ransack Gem !
With ransack search form, we had to use `url` because we're not using the search form on the resource controller's index action. We're using it on custom controller's index action i.e. Home's index not User's index. Whenever user performs search it will take to this URL


- views/home/index.html.erb 

```erb
<div class="col-lg-10 mx-auto mt-5">
  <div class="card mt-4 mb-4">
    <div class="card-body">
      <div class="text-center mb-3">Search developers across the world!</div>
      <%= search_form_for @q, url: root_path do |f| %>
        <div class="input-group mb-3">
          <%= f.search_field :country_or_city_cont, class: "form-control", placeholder: "Search by country or city" %>

          <%= f.submit "Search", class: "btn btn-primary"%>
          <%# <input type="text" class="form-control" placeholder="Search by country or city" aria-label="Search by country or city" aria-describedby="button-addon">
        <button type="button" id="button-addon" class="btn btn-primary">Search</button> %>
        </div>
      <% end %>
    </div>
  </div>
  <div class="row mt-4 mb-4">
    <% @users.each do |user|%>
      <div class="col-lg-3 b-3 mt-3">
        <div class="card text-center shadow" style="min-height: 400px;">
          <div class="card-body">
            <%= image_tag "user_avatar.png", style: "width: 150px; border-radius: 50%; border: 2px solid #53e9fu;" %>
            <div class="user-info">
              <h5><%= user.full_name%></h5>
              <p class="lead"><%= user.profile_title%></p>
              <small class="text-primary"><%= user.country%></small><br>
              <%= link_to "View Profile", "javascript:void(0)", class: "btn btn-primary mt-3" %>
            </div>
          </div>
        </div>
      </div>
    <% end %>
  </div>
</div>
```


Since we're searching by city or country name, we have to provide it in User model. 

```
  def self.ransackable_attributes(auth_object = nil)
    ["country", "city"]
  end
```

Since we're searching with two attributes, we also need to provide association in User model. If you had only user country for searching, then error won't occur and you won't have to write below line in User model. 
```
  def self.ransackable_associations(auth_object = nil)
    []
  end
```


# Working on user details action and custom routing


- [members_controller.rb]
```ruby
class MembersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
end
```

- [routes.rb]
```
  # get "member/:id" => "members#show"
  get "member/:id", to: "members#show", as: "member"
```

The first/traditional way of creating route won't generate the route helper path/url. In index.html.erb, you're forced to use `<%#= link_to "View Profile", "/member/#{user.id}", class: "btn btn-primary mt-3" %>`. However with second way to creating route, you can use both, 

- index.html.erb
```
<%#= link_to "View Profile", "/member/#{user.id}", class: "btn btn-primary mt-3" %>
<%= link_to "View Profile", member_path(user.id), class: "btn btn-primary mt-3" %>
```

              

