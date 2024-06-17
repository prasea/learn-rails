# Ruby on Rails #59 Hotwire Turbo Streams CRUD

```
- rails new turboapp -d=postgresql
- rails g scaffold message body:text

- Use below simple css for styling in application.html.erb
   <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
```

Task1: Add message without page refresh. So display form on index view.
` <%= render partial: "messages/form" , locals: {message: Message.new}%>`

## Re-render form when creating message !

```erb
[index.html.erb]
<p style="color: green">
  %= notice %>
</p>

<% content_for :title, "Messages" %>

<h1>Messages</h1>

<div id="new_message">
  <%= render partial: "messages/form" , locals: {message: Message.new}%>
</div>

<div id="messages">
  <%= render @messages%>
</div>

<%= link_to "New message" , new_message_path %>
```

```erb
[messages_controller.rb]
def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new_message", partial: "messages/form", locals: { message: Message.new })
          ]
        end
        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
      end
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new_message", partial: "messages/form", locals: { message: @message })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
    end
  end

```

When you create new message, the message is created but won't get added to table/list via `render @messages` in index. We have to refresh page to have the created message re-rendered !

- To have new messages on top

```
  def index
    @messages = Message.order(created_at: :desc)
  end
```

turbo_stream.update() replaces one element with other but using same turbo_frame_id.

```
[messages_controller=>create action]
    respond_to do |format|
      if @message.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new_message", partial: "messages/form", locals: { message: Message.new }),
            turbo_stream.prepend("messages", partial: "messages/message", locals: { message: @message })
          ]
        end
```

Turbo did 2 things :

1. Updated the form
2. Added new message on top of messages list

```erb
[_message.html.erb]
<div id="<%= dom_id message %>">
  <p>
    <strong>Body:</strong>
    <%= message.body %>
  </p>
  <div>
    <%= link_to "Edit", edit_message_path(message) %> |
    <%= button_to "Delete", message, method: :delete %>
  </div>
</div>
```

Each message wrapper div has unique id because of `dom_id`.

```
[application.html.erb]
  <%= Time.zone.now %>
```

When you Delete a message a page refresh occurs which can be validated by the change of time's value.

TASK : Remove message using turbo_stream without page refresh

```erb
  def destroy
    @message.destroy!

    respond_to do |format|
      # format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@message.id}") }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@message) }
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end
```

## TODO : Render edit form without page refresh

A better way to achieve this would be `turbo_frame` but we'll be using `turbo_stream`.

```rb
  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(@message, partial: "messages/form", locals: { message: @message })
      end
    end
  end
```

Now, when you click Edit on index view we get `ActionController::UnknownFormat in MessagesController#edit`.
Turbo Stream can respond to anything except GET while Turbo Frame can only respond to GET.

The `edit` action issues GET request which can't be handled by TurboStream.

The hack lies to make `edit` action respond with request other than GET. We change `routes.rb`,

```rb
  resources :messages do
    member do
      post :edit
    end
  end
```

Update the edit button on `_messages.html.erb` to issue POST request by changing link_to into button_to.

```erb
<div id="<%= dom_id message %>">
  <p>
    <strong>Body:</strong>
    <%= message.body %>
  </p>
  <div>
    <%= button_to "Edit", edit_message_path(message), method: :post %>
    <%= button_to "Delete", message, method: :delete %>
  </div>
</div>

```

At the moment, when you click Edit button, the mesage gets updated with form to edit message but after you acutaly change message and click update button, the page gets refreshed. To avoid it, in `update` action we have to respond with turbo_stream. In case message is updated respond with message partial else respond with edit form partial.

```rb
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@message, partial: "messages/message", locals: { message: @message })
        end
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@message, partial: "messages/form", locals: { message: @message })
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
```

## TODO : Update the message count using turbo_stream

In `index.html.erb`, `<%= Message.count %> Messages`. Message count should change when someone adds or destroy a message. But ATM, one has to manually refresh the page to see the change.

```rb
def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("new_message", partial: "messages/form", locals: { message: Message.new }),
            turbo_stream.prepend("messages", partial: "messages/message", locals: { message: @message }),
            # turbo_stream.update("message_counter", html: "#{Message.count}"),
            # turbo_stream.update("message_counter", html: Message.count),
            turbo_stream.update("message_counter", Message.count)

          ]
        end
        # Other codes as it is. . . .
```

In `index.html.erb`,

```erb
<h1>
  <span id="message_counter"><%= Message.count %></span> Messages
</h1>
```

Still message count doesn't get updates without page refresh in case of deleting. So,

```rb
  def destroy
    @message.destroy!

    respond_to do |format|
      # format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@message.id}") }
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@message),
            turbo_stream.update("message_counter", Message.count)
          ]
      end
      # Rest of codes . . .
```

To add flash notice message when CRUD operation is success. In `index.html.erb`, we have

```
<p id="notice" style="color: green">
  <%= notice %>
</p>
```

Hence in create, update and destroy action, add below turbo stream response with appropriate message,
`format.html { redirect_to message_url(@message), notice: "Message was successfully updated !" }`

# Ruby on Rails #60 Hotwire Turbo Streams Autocomplete Search

List of movies where we can search and auto-complete search.
To populate our movies table, we use `Faker`

```
  rails g scaffold Movies title:string
  rails db:migrate
  bundle add faker
```

- Validation on movies.rb model,

```
class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: true
end
```

- Seeding the data using Faker. db/seeds.rb

```
150.times do
  Movie.create(title: Faker::Movie.unique.title)
end
```

Now we need a search form in index. But before that let's create a search route. We won't pass movie_id into search action of controller, we'll only pass all the movies. Hence, we create `collection` instead of `member` route !

- routes.rb

```
  resources :movies do
    collection do
      post :search
    end
  end
```

You could also use `get` for search request. But to be compatible with TurboStream, we have to use `post` so that we can respond update using turbo_stream. If you want to use TurboFrame, you can use get request too!

- In movies/index.html.erb, add search form at top,

```
<%= form_with url: search_movies_path, method: :post do |form|%>
  <%= form.search_field :title_search%>
<% end %>
<div id="search_results">
  Search Results
</div>

```

Here :title_search is the params that gets sent to movies controller's `search` action. Using this params value, we'll update value inside search_results div using turbo_stream,

```
  def search
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("search_results", params[:title_search])
        ]
      end
    end
  end
```

ATM we submit the search form by pressing Enter key. Let's automatically submit search form on input,

```
<%= form_with url: search_movies_path, method: :post do |form|%>
  <%= form.search_field :title_search, oninput: "this.form.requestSubmit()"%>
<% end %>
<div id="search_results">
  Search Results
</div>
```

Each time type something on search form, form gets submitted with turbo_stream response from controller. For test purpose instead of populating params[:title_search], you could populate Time.zone.now,

```
  def search
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # turbo_stream.update("search_results", params[:title_search]),
          turbo_stream.update("search_results", Time.zone.now)
        ]
      end
    end
  end
```

Instead of displaying these useless information, we want to display the searched movie if exits. First let's display the count of found movies,

```
  def search
    @movies = Movie.where("title ILIKE ?", "%#{params[:title_search]}%")
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("search_results", @movies.count)
        ]
      end
    end
  end
```

We managed to display quantity of search result using turbo_stream. Now let's actually render them. For that we have to create a partial.

- Create file views/movies/\_search_results.html.erb

```
<%= movies.count %>
<% movies.each do |movie|%>
  <br>
  <%= movie.title%>
<% end %>

```

And from movies controller's search action we use this partial.

```
  def search
    @movies = Movie.where("title ILIKE ?", "%#{params[:title_search]}%")
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("search_results", partial: "movies/search_results", locals: { movies: @movies })
        ]
      end
    end
  end
```

- If you want the search result be highlighted with searched term, we can use `highlight` component.

```
<%= movies.count %>
<% movies.each do |movie|%>
  <br>
  <%= movie.title%>
  <%= highlight(movie.title, params[:title_search])%>
<% end %>
```

- You can turn returned found search results into links,

```
<%= movies.count %>
<% movies.each do |movie|%>
  <br>
  <%= movie.title%>
  <%= link_to highlight(movie.title, params[:title_search]), movie%>
<% end %>
```

- Event after you clear the search term from search form, the previosly returned search result isn't cleared. One solution is to check if :title_search params is present or not,

```

  def search
    if params[:title_search].present?
      @movies = Movie.where("title ILIKE ?", "%#{params[:title_search]}%")
    else
      @movies = []
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("search_results", partial: "movies/search_results", locals: { movies: @movies })
        ]
      end
    end
  end
```

- Move search query ILIKE from controller into model [movie.rb]

```
class Movie < ApplicationRecord
  validates :title, presence: true, uniqueness: true

  scope :filter_by_title, ->(title) { where("title ILIKE ?", "%#{title}%") }
end
```

- [movies_controller.rb]

```
  def search
    if params[:title_search].present?
      # @movies = Movie.where("title ILIKE ?", "%#{params[:title_search]}%")
      @movies = Movie.filter_by_title(params[:title_search])
    else
      @movies = []
    end
    respond_to do |format|
    # Rest of code . . .
```

TODO: To improvise further, we're gonna use stimulus. ATM, we're using `oninput: "this.form.requestSubmit()"` on search input. If user type `the` 3 requests are made for each letter. We can limit this request by adding `delayed submit`. We're gonna submit after half seconds after use inputs something.

- javascript/controller/debounce_controller.js

```js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Debounce controller connected !");
  }

  static targets = ["form"];

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 500);
  }
}
```

- \_search_form.html.erb

```erb
<%#= form_with url: search_movies_path, method: :post do |form|%>
  <%#= form.search_field :title_search, oninput: "this.form.requestSubmit()"%>
  <%# end %>

  <%= form_with url: search_movies_path, method: :post, data: {controller: "debounce", debounce_target: "form"} do |form|%>
    <%= form.search_field :title_search, data: {action: "input->debounce#search"}%>
  <% end %>

  <div id="search_results">
    Search Results
  </div>

```

# Ruby on Rails #63 Hotwire Modals (the right way)

`rails g scaffold posts title body:text`

- In application.html.erb, add turbo-frame so that we can open modal from anywhere in our app.
  `<%= turbo_frame_tag :modal%>`

When you click on `New post` on index view, you get below error,

**Error: The response (200) did not contain the expected <turbo-frame id="modal"> and will be ignored. To perform a full page visit instead, set turbo-visit-control to reload.**

After user clicks `New post`, the controller redirects to `new.html.erb` and it doesn't have corresponding turbo-frame with id :modal. Hence wrap all content of `new.html.erb` view with `turbo_frame_tag :modal`. But we use Deanin's modal,

```
<%= turbo_frame_tag :modal do %>
  <div class="modal">
    <h1>New post</h1>
    <%= render "form", post: @post %>
    <br>
    <div>
      <%= link_to "Cancel", "#", data: {
        controller: "turbomodal",
        action: "turbomodal#close"
      }, class: "cancel-button" %>
    </div>
  </div>
<% end %>
```

- Let's style modal,

```css
[application.css] .modal {
  position: fixed;
  z-index: 1;
  padding: 2em;

  /* Centering */
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);

  overflow: auto;
  background-color: rgb(0, 0, 0);
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 5px;
  /* Add the drop shadow */
  box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.2), 0 5px 10px 0 rgba(0, 0, 0, 0.19);
}

.cancel-button {
  background-color: #1530ff;
  font-size: 12px;
  color: white;
  padding: 4px 8px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  float: right;
  text-decoration: none;
}
.cancel-button:hover {
  background-color: #2640fe;
}
```

Q. How to replace empty turbo_frame_tag on application.html.erb with our modal?
`<%= link_to "New post", new_post_path, data: {turbo_frame: "modal"} %>`

Now when user clicks `New Post`, instead of going to target `new_post_path`, it puts content of target(new_post_path aka new.html.erb) into turbo_frame_tag of application.html.erb.

When you click on `Create Post` after filling title & body, you get below error,

**Error: The response (200) did not contain the expected <turbo-frame id="modal"> and will be ignored. To perform a full page visit instead, set turbo-visit-control to reload.**

After user clicks `Create Post`, the controller redirects to `show.html.erb` and it doesn't have corresponding turbo-frame with id :modal. Instead of controller redirecting to show view, we use turbo_stream to append newly added post in index view.

- To achieve that `create` action of `posts_controller`,

```
 def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("posts", partial: "posts/post", locals: { post: @post })
        end
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
```

format.turbo_stream has higher precedence over format.html.

Problems : The modal doesn't close after submitting valid form fields.Also if we don't have successfull form submission, we don't want to respond with turbo_stream and not dismiss the modal.

In TurboHandbook, at 2. Navigate with TurboDrive, we have Form Submission `turbo:submit-end`.

`rails g stimulus turbomodal`

```
[turbomodal_controller.js]
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbomodal"
export default class extends Controller {
  connect() {
    console.log("Connected to turbomodal")
  }
  submitEnd(e) {
    console.log(e)
    console.log(e.detail.success)
  }
}
```

- posts/new.html.erb

```erb
<%= turbo_frame_tag :modal do %>
  <div data-controller="turbomodal" data-action="turbo:submit-end->turbomodal#submitEnd">

    <% content_for :title, "New post" %>

    <h1>New post</h1>

    <%= render "form", post: @post %>

    <br>

    <div>
      <%= link_to "Back to posts", posts_path %>
    </div>
  </div>

<% end %>

```

When you click `New Post`, stimulus controller gets connected. When you click `Create Post`, in console you'll see CustomEvent that contains success true/false on `e.detail.success` object. Based on the value of success, we'll show/hide modal.

```js
import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="turbomodal"
export default class extends Controller {
  // connect() {
  //   console.log("Connected to turbomodal")
  // }
  submitEnd(e) {
    if (e.detail.success) {
      this.hideModal();
    }
  }

  hideModal() {
    this.element.remove();
  }

  // This is Deanin's action method
  close(e) {
    e.preventDefault();
    // Remove from parent
    const modal = document.getElementById("modal");
    modal.innerHTML = "";

    // Remove the src attribute from the turbo-frame modal in application.html.erb
    modal.removeAttribute("src");

    // Remove complete attribute from the turbo-frame modal in application.html.erb
    modal.removeAttribute("complete");
  }
}
```

Here we have perfect combination of using turbo-frame, turbo_stream and stimulus.

## TODO : Turbo modal to EDIT post.

- First of all, in the Edit button, add turbo_frame_tag,
  `<%= link_to "Edit this post", edit_post_path(@post), data: {turbo_frame: 'modal'} %>`

- Just like with `New Post`, we wrapped `new.html.erb`. With `Edit Post`, we wrap `edit.html.erb`,

```erb
<%= turbo_frame_tag :modal do %>
  <div data-controller="turbomodal" data-action="turbo:submit-end->turbomodal#submitEnd">

    <% content_for :title, "Editing post" %>

    <h1>Editing post</h1>

    <%= render "form", post: @post %>

    <br>

    <div>
      <%= link_to "Show this post", @post %> |
      <%= link_to "Back to posts", posts_path %>
    </div>
  </div>
<% end%>

```

- Finally in `posts_controller`,

```
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@post, partial: "posts/post", locals: { post: @post })
        end
        # Rest of code . . .
```

RECAP: On New and Edit links we added `data-turbo-frame :modal` that targets application.html.erb's turbo_frame_tag :modal.
We used **Rules 3: A link can target another frame than the one it is directly nested in thanks to the data-turbo-frame data attribute.**
And on application.html.erb <turbo-frame id="modal"></turbo-frame>, it adds content from turbo_frame_tag of new & edit. Also we used stimlus to check if form submission was successful or not just to close modal.
