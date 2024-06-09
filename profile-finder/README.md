# Setting up project !

- `$ rails new profile-finder --database=postgresql`
- `$ bundle add cssbundling-rails`
- `$ rails css:install:bootstrap`
  To add bootstrap and popper.js into importmap.rb
- `$ ./bin/importmap pin bootstrap`
- `$ rails g controller home index`
- In routes.rb, replace get 'home/index' with root 'home#index'
- `$ rails g resource User name email city state country phone`

# Understanding and working with stimulus controller !

- `$ rails g stimulus user_modal`
  We'll use user_modal stimulus to popup bootstrap modal for new, edit and show actions
  Q. How we can send request to new action of users_controller in rails using turbo_stream?
  In index.html.erb of users_controller,
  Option 1: `<%= link_to "New user", new_user_path(format: :turbo_stream)%>`
  Option 2: `<%= link_to "New user", new_user_path, "data-controller": "user-modal"%>`
  The better syntax for Option 2 is,
  `<%= link_to "New user", new_user_path, data: {controller: "user-modal"}%>`

# Display Rails forms in bootstrap modal using turbo hotwire

`rails g stimulus bs_modal`

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

We'll open bs modal using generated bs_modal stimulus controller

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

We removed the modal-body & modal-foooter div from bs modal which we'll use in \_form partial,

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

TASK: Now we need to place our modal into turbo_frame_tag "remote_modal" template with target `_top`. Also render the \_form partial from bs modal partial !

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
