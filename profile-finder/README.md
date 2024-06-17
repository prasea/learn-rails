# Setting up project !

- `$ rails new profile-finder --database=postgresql`
- `$ bundle add cssbundling-rails`
- `$ rails css:install:bootstrap`
  To add bootstrap and popper.js into [config/importmap.rb]
- `$ ./bin/importmap pin bootstrap`
- `$ rails g controller home index`
- In routes.rb, replace get 'home/index' with root 'home#index'
- application.html.erb

```
    <div class="container">
      <div class="row">
        <%= yield %>
      </div>
    </div>

```

- If you want to perform CRUD action manually
  `$ rails g resource User name email city state country phone`
- If you want CRUD action methods auto generated
  `$ rails g scaffold User name email city state country phone`

When you click on `New User` button, the request is processed as HTML but after filling all the fields when you click on `Create User`, the request is processed as TURBO_STREAM which can be verified from server logs.

But in users controller's create action, the redirect is still as format.html but our request is coming as TURBO_STREAM. Basically we're not handling the incoming TURBO_STREAM request.

Upto Rails6, the scaffold command used to provide tabular view of all datas on index view. But since Rails7, we get listing view of all datas on index. Let's make tabular index and also add unique id to each table row

```
[app/views/users/index.html.erb]
<p style="color: green"><%= notice %></p>

<h1>Users</h1>

<table class="table table-bordered">
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>City</th>
      <th>State</th>
      <th>Country</th>
      <th>Phone</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user|%>
      <%= render user%>
    <% end %>
  </tbody>
</table>

<%= link_to "New user", new_user_path %>

[app/views/users/user.html.erb]
<tr id="user_row_<%= user.id%>">
  <td><%= user.name%></td>
  <td><%= user.email%></td>
  <td><%= user.city%></td>
  <td><%= user.state%></td>
  <td><%= user.country%></td>
  <td><%= user.phone%></td>
  <td>
    <%= link_to "View", user_path(user), class: 'btn btn-info'%>
    <%= link_to "Edit", edit_user_path(user), class: 'btn btn-success'%>
    <%= link_to "Delete", user_path(user), method: :delete, data: {confirm: 'Are you sure?'}, class: 'btn btn-danger'%>
  </td>
</tr>

```

- Styling users/\_form.html.erb with bootstrap

```
<%= form_with(model: user) do |form| %>
  <div class="modal-body">

    <% if user.errors.any? %>
      <div style="color: red">
        <h2><%= pluralize(user.errors.count, "error") %> prohibited this user from being saved:</h2>

        <ul>
          <% user.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class= 'form-group mb-3'>
      <%= form.label :name, class: 'form-label mb-2' %>
      <%= form.text_field :name, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :email, class: 'form-label mb-2' %>
      <%= form.text_field :email, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :city, class: 'form-label mb-2' %>
      <%= form.text_field :city, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :state, class: 'form-label mb-2' %>
      <%= form.text_field :state, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :country, class: 'form-label mb-2' %>
      <%= form.text_field :country, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :phone, class: 'form-label mb-2' %>
      <%= form.text_field :phone, class: 'form-control form-control-lg'%>
    </div>
  </div>
  <div class="modal-footer">
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
    <%= form.submit class: "btn btn-primary", data: {action: "click->bs-modal#submitEnd"}%>
  </div>
  <div>
  </div>
<% end %>

```

When you clone this repo and run `rails server`, if you got below error,

```
Sprockets::Rails::Helper::AssetNotFound in Home#index Showing /media/parajanya/TheOffice/Garo-Cha/learn-rails/profile-finder/app/views/layouts/application.html.erb where line #8 raised: The asset "application.css" is not present in the asset pipeline.
Extracted source (around line #9):

<%= csp_meta_tag %>

<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>

<%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>

</head>

So from my understanding it's looking for a aplication.css file in stylesheet folder but when I created it with bootstrap it was replace by aplication.bootstrap.scss.


SOLUTION:
Since we are adding bootstrap to the rails project AFTER creating it, I'd recommend first running:
  rails assets:precompile
```

# Understanding and working with stimulus controller !

- `$ rails g stimulus user_modal`
  We'll use user_modal stimulus to popup bootstrap modal for new, edit and show actions

  Q. How we can send request to new action of users_controller in rails using turbo_stream instead of HTML? There are 2 ways :
  In index.html.erb of users_controller,
  Option 1: `<%= link_to "New user", new_user_path(format: :turbo_stream)%>`
  Option 2: `<%= link_to "New user", new_user_path, "data-controller": "user-modal"%>`
  The better syntax for Option 2 is,
  `<%= link_to "New user", new_user_path, data: {controller: "user-modal"}%>`

- Generate user_modal stimuls controller
  `rails g stimuls user_modal`

```js
import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="user-modal"
export default class extends Controller {
  connect() {
    console.log("I am connected !!!");
  }

  initialize() {
    this.element.setAttribute("data-action", "click->user-modal#showModal");
  }
}
```

Result: Now if you inspect `New User` button it should have data-controller and data-action attributes for stimulus controller. Let's add `showModal` action method in stimulus controller

```js
[user_modal_controller.js];
import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="user-modal"
export default class extends Controller {
  connect() {
    console.log("I am connected !!!");
  }

  initialize() {
    this.element.setAttribute("data-action", "click->user-modal#showModal");
  }
  showModal(e) {
    e.preventDefault();
    this.url = this.element.getAttribute("href");
    console.log(this.url);
    // Making request to new action of users_controller as turbo_stream instead of as HTML
    fetch(this.url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}
```

At the moment, if you click on `New User` button, you get below error,

```
ActionController::UnknownFormat in UsersController#new
UsersController#new is missing a template for this request format and variant.
request.formats: ["text/vnd.turbo-stream.html"]
request.variant: []
```

The reason for this error is we only have `new.html.erb`. But we should now have `new.turbo_stream.erb` which is missing ATM !

# Display Rails forms in bootstrap modal using turbo hotwire

`rails g stimulus bs_modal`

First when this controller gets connected to DOM element i.e. where data-controller="bs-modal" attribute is defined, then we need to show bootstrap modal.

```
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bs-modal"
export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  //Once the bs modal server the purpose of view, edit or new. It needs to close and once it is closed, we need to disconnect as well
  disconnect() {
    this.modal.hide();
  }

  //Hide bs modal once new or edit form is submitted successfully
  submitEnd(event) {
    this.modal.hide();
  }
}
```

One thing to make sure for this bs_modal stimulus to work is to make bootstrap available at window level !
In [app/javascripts/application.js], add below statement else bs modal won't work.
`window.bootstrap = bootstrap`

[Bootstrap 5 ReferenceError: bootstrap is not defined](https://stackoverflow.com/questions/64113404/bootstrap-5-referenceerror-bootstrap-is-not-defined)
Hence, use `window.Modal = bootstrap.Modal;`

In `application.html.erb` layout view, add placeholder to render bs modal,
`<%= turbo_frame_tag "remote_modal"%>`

We'll open bs modal using generated bs_modal stimulus controller. So in `_form_modal.html.erb`, you should link `data-controller="bs-modal"`

```erb
[app/views/users/_form_modal.html.erb]
<div class="modal" tabindex="-1" data-controller="bs-modal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Modal title</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
    </div>
  </div>
</div>

```

We removed the modal-body & modal-foooter div from bs modal which we'll use in `_form` partial. In modal-body we'll render form fields and in modal-footer, we'll show Cancel & Submit button. With Submit button we'll also add `data: {action: "click->bs-modal#submitEnd"}`

```erb
[app/views/users/_form.html.erb]
<%= form_with(model: user) do |form| %>
  <div class="modal-body">
    <p>Modal body text goes here.</p>

    <% if user.errors.any? %>
      <div style="color: red">
        <h2><%= pluralize(user.errors.count, "error") %> prohibited this user from being saved:</h2>

        <ul>
          <% user.errors.each do |error| %>
            <li><%= error.full_message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class= 'form-group mb-3'>
      <%= form.label :name, class: 'form-label mb-2' %>
      <%= form.text_field :name, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :email, class: 'form-label mb-2' %>
      <%= form.text_field :email, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :city, class: 'form-label mb-2' %>
      <%= form.text_field :city, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :state, class: 'form-label mb-2' %>
      <%= form.text_field :state, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :country, class: 'form-label mb-2' %>
      <%= form.text_field :country, class: 'form-control form-control-lg'%>
    </div>

    <div class= 'form-group mb-3'>
      <%= form.label :phone, class: 'form-label mb-2' %>
      <%= form.text_field :phone, class: 'form-control form-control-lg'%>
    </div>
  </div>
  <div class="modal-footer">
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
    <%= form.submit class: "btn btn-primary", data: {action: "click->bs-modal#submitEnd"}%>
  </div>
  <div>
  </div>
<% end %>
```

TASK: Now we need to place our modal into turbo_frame_tag "remote_modal" template with target `_top`. Also render the `_form` partial from bs modal partial !

```erb
[_form_modal.html.erb]
<%= turbo_frame_tag "remote_modal", target: "_top" do %>
  <div class="modal" tabindex="-1" data-controller="bs-modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Modal title</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <%= render "form", user: @user%>
      </div>
    </div>
  </div>
<%end%>

```

TASK : Rename the view template from new.html.erb to new.turbo_stream.erb.

```erb
[new.turbo_stream.erb]
<%= turbo_stream.replace "remote_modal" do %>
  <%= render "form_modal", user: @user%>
<% end %>

```
