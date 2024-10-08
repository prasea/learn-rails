# README
Building a developers community application in Rails 7.2


# Install Twitter Bootstrap and Add Header-Footer partials
Since we have `cssbundling-rails` gem. Run `rails css:install:bootstrap` to install boostrap in your project 

Running this command will generate app/assets/builds/applications.css containing all bootstrap's CSS properties. Also stylesheets/application.css becomes stylesheets/application.bootstrap.scss

If it happens, Bootstrap is successfully installed in our project. Since bootstrap has dependency on popper js, we need to pin it, 

`./bin/importmap pin boostrap` command will add below two lines in config/importmap.rb 
pin "bootstrap" # @5.3.3
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8


Create header & footer partial in [views/shared] and render it from [application.html.erb]

# Create User Model for Authentication using Devise Gem
rails g devise:install 

- Generate devise user model with custom attributes 
`rails g devise user first_name last_name date_of_birth:date username city  state country pincode street_address profile_title about:text`

In generate migration file, we'll uncomment the **Trackable** devise module's attributes and also uncomment it from the generate [user.rb] model. 

# Using Faker gem to generate dummy data for user model

We forgot to add the `contact_number` attribute to users table
`rails g migration add_contact_number_to_users contact_number:string`


- Creating a pre-defined values for `profile_title` attribue 
[models/user.rb]
```ruby
  PROFILE_TITLE = [
    "Junior Ruby on Rails",
    "Mid Level Ruby on Rails",
    "Senior Ruby on Rails",
    "Software Engineer",
    "QA Engineer",
    "Platform Engineer",
    "Fullstack Ruby on Rails",
    "Frontend Engineer"
  ].freeze
```

#### Create a database seed 
- The value of `date_of_birth` will be atleast 24 years of age. 
[db/seeds.rb]
```ruby
User.destroy_all
ActiveRecord::Base.transaction do
  100.times do  |i|
    user = User.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      username: "#{Faker::Name.first_name}-#{i+5}",
      profile_title: User::PROFILE_TITLE.sample,
      email: Faker::Internet.email,
      password: "password",
      date_of_birth:(Date.today + rand(1..30).days) - rand(24..35).years,
      country: Faker::Address.country,
      state: Faker::Address.state,
      city: Faker::Address.city,
      pincode: Faker::Address.postcode,
      contact_number: Faker::PhoneNumber.phone_number_with_country_code,
      about:"As a seasoned Full Stack Software Engineer, I bring a wealth of expertise in designing and implementing robust, scalable applications. Proficient in both front-end and back-end technologies, I excel in creating seamless user experiences and efficient server-side solutions. My skill set includes JavaScript, React, Ruby on Rails, Node.js, and database management with SQL and NoSQL. With a passion for continuous learning and staying abreast of industry trends, I thrive in collaborative environments and enjoy tackling complex problems. My commitment to code quality and best practices ensures the delivery of high-performing, maintainable software solutions."
    )
    puts "User #{i+1} created !"
  end
end
```

# Working with Bootstrap Grid System to Display List of Users
In [route.rb], the root path is `root "home#index"`

[home_controller.rb]
```ruby 
class HomeController < ApplicationController
  def index
    @users = User.all
  end
end
```


[views/home/index.html.erb]
```html
<div class="col-lg-10 mx-auto mt-5">
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
              <%= link_to "View Profile", "javscript:void(0)", class: "btn btn-primary mt-3" %>
            </div>
          </div>
        </div>
      </div>
    <% end %>
  </div>
</div>
```

Instead of calling `user.first_name` and `user.last_name`, we called `user.full_name`. But that `full_name` method must be present in User model,
```ruby 
def full_name
  "#{first_name} #{last_name}".strip
end
```

`style="min-height: 400px;"` was added to make all the card equi-height. 


Instead of showing all database records, let's implement a `limit` to only show few user records in user view. 

[home_controller.rb]
```ruby 
class HomeController < ApplicationController
  def index
    # @users = User.all
    @users = User.limit(16).order(created_at)
  end
end
```


# Working with Bootstrap Input Group and Rails forms
Let's create an search form UI. It won't be functional for now. we'll use bootstrap's input group component to have input and button side-by-side.
[index.html.erb]
```html
  <div class="card mt-4 mb-4">
    <div class="card-body">
      <div class="text-center mb-3">Search developers across the world!</div>
      <div class="input-group mb-3">
        <input type="text" class="form-control" placeholder="Search by country or city" aria-label="Search by country or city" aria-describedby="button-addon">
        <button type="button" id="button-addon" class="btn btn-primary">Search</button>
      </div>
    </div>
  </div>
```


# Implement user search using Ransack Gem
[Extensive documentation on Ransack](https://activerecord-hackery.github.io/ransack/)

Update the [home_controller.rb]
```ruby
class HomeController < ApplicationController
  def index
    # @users = User.all
    @q = User.ransack(params[:q])
    @users = @q.result().limit(20).order(:created_at)
  end
end
```


With ransack search form, we had to use `url` because we're not using the search form on the resource controller's index action. We're using it on custom controller's index action i.e. Home's index not User's index. Whenever user performs search it will take to this URL


- views/home/index.html.erb 
```html
<div class="col-lg-10 mx-auto mt-5">
  <div class="card mt-4 mb-4">
    <div class="card-body">
      <div class="text-center mb-3">Search developers across the world!</div>
      <%= search_form_for @q, url: root_path do |f| %>
        <div class="input-group mb-3">
          <%# <input type="text" class="form-control" placeholder="Search by country or city" aria-label="Search by country or city" aria-describedby="button-addon">          
          <%= f.search_field :country_or_city_cont, class: "form-control", placeholder: "Search by country or city", area: { label: "Search  by country or city", describedby: "button-addon" } %>

          <%= f.submit "Search", class: "btn btn-primary", id: "button-addon"%>
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
```ruby
  def self.ransackable_attributes(auth_object = nil)
    ["country", "city"]
  end
```

Since we're searching with two attributes, we also need to provide association in User model. If you had only user country for searching, then error won't occur and you won't have to write below line in User model. 
```ruby
  def self.ransackable_associations(auth_object = nil)
    []
  end
```

If still you get, NoMethodError in HomeController#index
**undefined method `with_connection' for an instance of ActiveRecord::ConnectionAdapters::PostgreSQLAdapter**
Did you mean? raw_connection
[View this PR to solve](https://github.com/activerecord-hackery/ransack/pull/1493)
`bundle show ransack` to get the path where ransack is installed. 


# Working on user details action and custom routing
Though we're working on the **user** resource, we're not creating `users_controller` to avoid conflict with devise routes. We'll create a separate `members_controller` that'll operate on the user resource. 

- [members_controller.rb]
```ruby
class MembersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
end
```

- [routes.rb]
```ruby
  # get "member/:id" => "members#show"
  get "member/:id", to: "members#show", as: "member"
```

The first/traditional way of creating route won't generate the route helper path/url. In [home/index.html.erb], you're forced to use `<%#= link_to "View Profile", "/member/#{user.id}", class: "btn btn-primary mt-3" %>`. However with second way to creating route, you can use both, 

[home/index.html.erb]
```erb
<%#= link_to "View Profile", "/member/#{user.id}", class: "btn btn-primary mt-3" %>
<%= link_to "View Profile", member_path(user.id), class: "btn btn-primary mt-3" %>
```

              


# Rails forms in bootstrap modal with turbo-hotwire and stimulus controller

In bs_modal stimulus controllers connect() action method, we write code to open bootstrap modal as soon as it finds DOM element having data-controller attribute with value bs-modal i.e. `data-controller="bs-modal"`


```
connect() {
  this.modal = new bootstrap.Modal(this.element, {
    keyboard: false
  })
  this.modal.show()
}
```

this.modal will initialize the new bootstrap modal. this.element is the DOM element having attribute `data-controller="bs-modal"`. 

disconnect() will be invoked to hide the bootstrap modal from DOM. 
```
disconnect() {
  this.modal.hide()
}
```


We'll write additional action method same as disconnect that will work for forms within the bootstrap modal. When you submit the form within the bootstrap modal, it will close/hide the modal from DOM. We'll invoke this action method on "Submit" button clicked
```
submitEnd(e) {
  this.modal.hide()
}
```


The most important step is to define bootstrap in [app/javascript/application.js] as window.bootstrap. 
`window.bootstrap = bootstrap`

Let's implement the functionality such that user will be able to edit their bio/description. For that we need routes, controller action method. 

- [members_controller.rb]
```
def edit_description
  @user = User.find(params[:id])
end
```

- routes.rb 
`get "edit_description/:id", to: "members#edit_description", as: "edit_member_description"`

In [show.html.erb], create an edit link for About
```
<div class="col-lg-6">
  <div class="d-flex justify-content-end">
    <%= link_to edit_member_description_path(@user), data: {controller: "edit-user-description"} do %>
      <i class="bi bi-pencil-fill"></i>
    <% end %>
  </div>
</div>
```

Generate the stimulus to convert the request for Edit from text/html into text/vnd.turbo-stream.html
`rails g stimulus edit_user_description`

In this stimulus controller `this.element` is the DOM element having `data-controller="edit-user-description"`. 

```javascript
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-user-description"
export default class extends Controller {
  connect() {
  }

  initialize() {
    this.element.setAttribute("data-action", "click->edit-user-description#showModal")
  }

  showModal(e) {
    e.preventDefault();
    this.url = this.element.getAttribute("href")
    fetch(this.url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}

```

Q. Can we render .html.erb partial from .turbo_stream.erb template? Yes ! After we add `data-controller="bs-modal"` attribute to the boostrap modal, it will connect the modal with stimulus controller. We won't submit the form now, hence added empty(#) url to the form. 

- [views/members/_edit_description.popup.html.erb]
```erb
<%= turbo_frame_tag :remote_modal, target: :_top do %>
  <!-- Modal -->
  <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" data-controlelr="bs-modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="exampleModalLabel">Modal title</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <%= form_with model: @user, url: "#" do |form|%>
          <div class="modal-body">
            <div class="row">
              <div class="col-lg-12">
                <div class="form-group">
                  <%= form.label :description, class: "mb-3"%>
                  <%= form.text_area :about, value: @user.about, class: "form-control", rows: 15%>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <%= form.submit "Save", data: {action: "click->bs-modal#submitEnd" }, class: "btn btn-primary"%>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        <% end %>
      </div>
    </div>
  </div>
<% end %>
```




Last step is to render this partial into action template for our edit_description action. We'll render above partial on turbo-frame :remote_modal. When user clicks on the Edit button, the controller looks for file name `edit_description.turbo_stream.erb`


- [views/members/edit_description.turbo_stream.erb]
```
<%= turbo_stream.replace "remote_modal" do %>
  <%= render "edit_description_popup" %>
<% end %>
```


When you click on Edit link on bio/description if your application is still rendering the `edit_description` action as HTML instead of Turbo Stream. Your edit_description action in MembersController should explicitly render the Turbo Stream format when requested. Here's how you can adjust it

- [members_controller.rb]
```
class MembersController < ApplicationController
  before_action :set_member
  def show
  end

  def edit_description
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  private
  def set_member
    @user = User.find(params[:id])
  end
end
```

# Update user description with turbo-stream format 

[routes.rb]
`patch "update_description/:id", to: "members#update_description", as: "update_member_description"`

- [members_controller.rb]
```
class MembersController < ApplicationController
  before_action :set_member
  def show
  end

  def edit_description
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  def update_description 
  end

  private
  def set_member
    @user = User.find(params[:id])
  end
end
```

If you try to "Update", in server log you'll get below log
```
Started PATCH "/update_description/1" for ::1 at 2024-07-15 21:55:57 +0545
Processing by MembersController#update_description as TURBO_STREAM
  Parameters: {"authenticity_token"=>"[FILTERED]", "user"=>{"about"=>"Hello"}, "commit"=>"Save", "id"=>"1"}
  User Load (0.5ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 1], ["LIMIT", 1]]
  ↳ app/controllers/members_controller.rb:26:in `set_member'
No template found for MembersController#update_description, rendering head :no_content
Completed 204 No Content in 7ms (ActiveRecord: 0.5ms (1 query, 0 cached) | GC: 0.1ms)

```

We'll use turbo_stream.replace() for which we have to create partial for bio/decription, 

- [_member_description.html.erb]
`<p class="lead" id="member-description"><%= user.about%></p>`





Provide locals to above partial from [show.html.erb]. The last one is the most latest syntax. 
```
<!-- <p class="lead" id="member-description"><%#= @user.about%></p> -->
<%#= render partial: "member_description", locals: {user: @user}%>
<%= render "member_description", user: @user %>
```

- [members_controller.rb]
```
  def update_description
    respond_to do |format|
      if @user.update(about: params[:user][:about])
        format.turbo_stream { render turbo_stream: turbo_stream.replace("member-description", partial: "members/member_description", locals: { user: @user }) }
      else
        format.html { render :edit_description }  # Handle validation errors if any
      end
    end
  end
```


# Handling update operation for signed in users only

- [show.html.erb]
```
<% if user_signed_in? && current_user == @user%>
  <div class="col-lg-6">
    <div class="d-flex justify-content-end">
      <%= link_to edit_member_description_path(@user), data: {controller: "edit-user-description",} do %>
        <i class="bi bi-pencil-fill"></i>
      <% end %>
    </div>
  </div>
<% end %>
```

Using just this devise helper function is fine but we'll use `before_action authenticate_user!` to force filter only authenticated user to certain action methods of members_controller.

- [members_controller.rb]
```
class MembersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit_description update_description]
  def show
    @user = User.find(params[:id])
  end

  def edit_description
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  def update_description
    respond_to do |format|
      if current_user.update(about: params[:user][:about])
        format.turbo_stream { render turbo_stream: turbo_stream.replace("member-description", partial: "members/member_description", locals: { user: current_user }) }
      else
        format.html { render :edit_description }  # Handle validation errors if any
      end
    end
  end
end

```
Since only authenticated user can access the edit_description & update_description action methods, the corresponding views will have access to `current_user` devise helper method.  

As we're not extracting the user id from params, we need to change routes, 
```
get "edit_description", to: "members#edit_description", as: "edit_member_description"
patch "update_description", to: "members#update_description", as: "update_member_description"
```

Also for _edit_descrition_popup.html.erb partial we'll pass the user as locals from [edit_description.turbo_stream.erb]
```
<%= turbo_stream.replace "remote_modal" do %>
  <%= render "edit_description_popup", user: current_user %>
<% end %>
```


[_edit_descrition_popup.html.erb]
```
<%= turbo_frame_tag :remote_modal, target: :_top do%>
  <!-- Modal -->
  <div class="modal" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" data-controller="bs-modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="exampleModalLabel">Modal title</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <%= form_with model: user, url: update_member_description_path, method: :patch do |form|%>
          <div class="modal-body">
            <div class="row">
              <div class="col-lg-12">
                <div class="form-group">
                  <%= form.label :description, class: "mb-3"%>
                  <%= form.text_area :about, value: user.about, class: "form-control", rows: 15%>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <%= form.submit "Save", data: {action: "click->bs-modal#submitEnd" }, class: "btn btn-primary"%>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        <% end %>
      </div>
    </div>
  </div>
<% end %>

```

# Update user personal details with turbo-stream format

-[routes.rb]
```
  get "edit_profile", to: "members#edit_profile", as: "edit_member_profile"
  patch "update_profile", to: "members#update_profile", as: "update_member_profile"
```

- [members_controller.rb]
```ruby
class MembersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit_description update_description edit_profile update_profile]
  def show
    @user = User.find(params[:id])
  end

  def edit_description
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  def update_description
    respond_to do |format|
      if current_user.update(about: params[:user][:about])
        format.turbo_stream { render turbo_stream: turbo_stream.replace("member-description", partial: "members/member_description", locals: { user: current_user }) }
      else
        format.html { render :edit_description }  # Handle validation errors if any
      end
    end
  end

  def edit_profile
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  def update_profile
    
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :city, :state, :country, :pincode, :profile_title)
  end
end
```


- Generate the simulus controller that will change the request from text/html to TURBO_STREAM when Edit Profile button will be clicked 
`rails g stimulus edit_user_profile`

- [eidt_user_profile_controller.js]
```js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-user-profile"
export default class extends Controller {
  connect() {
    console.log("Edit user profile button is clicked !")
  }

  initialize() {
    this.element.setAttribute("data-action", "click->edit-user-profile#showModal")
  }

  showModal(event) {
    event.preventDefault();
    const url = this.element.getAttribute("href");

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text();
      })
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => console.error('There was a problem with the fetch operation:', error));
  }
}
```


In [show.html.erb] replace the card content where we display profile information with partial. Turbo Stream template will use it !
`<%= render "member_profile", user: current_user%>` - DO NOT use this. I made this mistake. Use below locals `@user` available in show view as unique user from params.
`<%= render "member_profile", user: @user%>`

- [_member_profile.html.erb]
```
<div class="card mb-5" id="member-profile">
  <div class="row">
    <div class="col-lg-4">
      <%= image_tag "user_avatar.png", class: "img-fluid"%>
    </div>
    <div class="col-lg-8 d-flex align-items-center">
      <div class="card-body">
        <h3 class="fw-bold"><%= user.full_name%></h3>
        <p class="lead"><%= user.profile_title%></p>
        <p class="lead text-primary"><%= user.country%></p>
        <% if user_signed_in? && current_user == user%>
          <%= link_to "Edit Profile", edit_member_profile_path, data: {controller: "edit-user-profile"}, class: "btn btn-primary" %>
        <% end%>
      </div>
    </div>
  </div>
</div>
```

- [edit_profile.turbo_stream.erb]
```
<%= turbo_stream.replace "remote_modal" do %>
  <%= render "edit_profile_popup", user: current_user %>
<% end %>
```

- [edit_profile_popup.html.erb]
```erb
<%= turbo_frame_tag :remote_modal, target: :_top do %>
  <!-- Modal -->
  <div class="modal" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" data-controller="bs-modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="exampleModalLabel">Edit Profile</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <%= form_with model: user, url: update_member_profile_path, method: :patch do |form| %>
          <div class="modal-body">
            <div class="row">
              <!-- Full Names -->
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :first_name, class: "my-2" %>
                  <%= form.text_field :first_name, class: "form-control" %>
                </div>
              </div>
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :last_name, class: "my-2" %>
                  <%= form.text_field :last_name, class: "form-control" %>
                </div>
              </div>
            </div>

            <!-- Address Information -->
            <div class="row">
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :city, class: "my-2" %>
                  <%= form.text_field :city, class: "form-control" %>
                </div>
              </div>
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :state, class: "my-2" %>
                  <%= form.text_field :state, class: "form-control" %>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :country, class: "my-2" %>
                  <%= form.text_field :country, class: "form-control" %>
                </div>
              </div>
              <div class="col-lg-6">
                <div class="form-group">
                  <%= form.label :contact_number, class: "my-2" %>
                  <%= form.text_field :contact_number, class: "form-control" %>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-lg-12">
                <div class="form-group">
                  <%= form.label :profile_title, class: "my-2" %>
                  <%= form.text_field :profile_title, class: "form-control" %>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <%= form.submit "Save", data: { action: "click->bs-modal#submitEnd" }, class: "btn btn-primary" %>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        <% end %>
      </div>
    </div>
  </div>
<% end %>

```


- [members_controller.rb]
```ruby
def edit_profile
    respond_to do |format|
      format.turbo_stream # Ensure Turbo Stream format is handled
    end
  end

  def update_profile
    respond_to do |format|
      if current_user.update(user_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace("member-profile", partial: "members/member_profile", locals: { user: current_user }) }
      else
        format.html { render :edit_description }  # Handle validation errors if any
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :city, :state, :country, :pincode, :profile_title)
  end
```


# Refactoring stimulus controller to display bootstrap modal - Part I

One common partial for rendering boostrap modal and then we can use this partial at all places where we need to display bootstrap modal using turbo stream. 
At the moment, we're rendering [_edit_profile_popup.html.erb] & [_edit_description_popup.html.erb] from [edit_profile.turbo_stream.erb] and [edit_description.turbo_stream.erb]. Both these partial consist of common boostrap modal codes. Let's use dynamic partial. 


- [shared/_turbo_modal.html.erb]
```erb
<%= turbo_frame_tag :remote_modal, target: :_top do%>
  <!-- Modal -->
  <div class="modal" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" data-controller="bs-modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="exampleModalLabel"><%= modal_title%></h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <%= render form_partial, user: user%>
      </div>
    </div>
  </div>
<% end %>
```

`form_partial` locals is dynamically supplied from edit profile & description turbo stream templates. Also note that `user` locals supplied will be only available on "shared/turbo_modal" partial. We have to again pass `user` locals to respective form partials. 

- [edit_profile.turbo_stream.erb]
```
<%= turbo_stream.replace "remote_modal" do %>
  <%#= render "edit_profile_popup", user: current_user %>
  <%= render "shared/turbo_modal", user: current_user, modal_title: "Edit Profile", form_partial: "members/edit_profile_popup" %>
<% end %>
```

- [edit_description.turbo_stream.erb]
```
<%= turbo_stream.replace "remote_modal" do %>
  <%#= render "edit_description_popup", user: current_user %>
  <%= render "shared/turbo_modal", user: current_user, modal_title: "Edit Description", form_partial: "members/edit_description_popup" %>
<% end %>
```

- [_edit_profile_popup.html.erb]
```
<%= form_with model: user, url: update_member_profile_path, method: :patch do |form| %>
  <div class="modal-body">
    <div class="row">
      <!-- Full Names -->
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :first_name, class: "my-2" %>
          <%= form.text_field :first_name, class: "form-control" %>
        </div>
      </div>
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :last_name, class: "my-2" %>
          <%= form.text_field :last_name, class: "form-control" %>
        </div>
      </div>
    </div>

    <!-- Address Information -->
    <div class="row">
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :city, class: "my-2" %>
          <%= form.text_field :city, class: "form-control" %>
        </div>
      </div>
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :state, class: "my-2" %>
          <%= form.text_field :state, class: "form-control" %>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :country, class: "my-2" %>
          <%= form.text_field :country, class: "form-control" %>
        </div>
      </div>
      <div class="col-lg-6">
        <div class="form-group">
          <%= form.label :contact_number, class: "my-2" %>
          <%= form.text_field :contact_number, class: "form-control" %>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-lg-12">
        <div class="form-group">
          <%= form.label :profile_title, class: "my-2" %>
          <%= form.text_field :profile_title, class: "form-control" %>
        </div>
      </div>
    </div>
  </div>
  <div class="modal-footer">
    <%= form.submit "Save", data: { action: "click->bs-modal#submitEnd" }, class: "btn btn-primary" %>
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
  </div>
<% end %>

```

- [_edit_description_popup.html.erb]
```
<%= form_with model: user, url: update_member_description_path, method: :patch do |form|%>
  <div class="modal-body">
    <div class="row">
      <div class="col-lg-12">
        <div class="form-group">
          <%= form.label :description, class: "mb-3"%>
          <%= form.text_area :about, value: user.about, class: "form-control", rows: 15%>
        </div>
      </div>
    </div>
  </div>
  <div class="modal-footer">
    <%= form.submit "Save", data: {action: "click->bs-modal#submitEnd" }, class: "btn btn-primary"%>
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
  </div>
<% end %>
```

# Refactoring stimulus controller to display bootstrap modal - Part II

Currently we have two different stimulus controllers [edit_user_profile_controller.js] and [edit_user_description_controller.js] serving similar purpose of changing the request/response from HTML to TURBO_STREAM. Instead use generic controller `Turbo`


- [turbo_controller.js]
```js
// edit_user_description_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Edit user description button clicked")
  }

  initialize() {
    this.element.setAttribute("data-action", "click->turbo#showModal")
  }

  showModal(event) {
    event.preventDefault();
    const url = this.element.getAttribute("href");

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text();
      })
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => console.error('There was a problem with the fetch operation:', error));
  }
}

```

Wherever you had used the previous two controller in DOM replace with `turbo`

### [Hotwire Modals - Drifting Ruby](https://www.youtube.com/watch?v=9aYaVq-e7VU)
