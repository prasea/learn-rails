# README

- rails new turboapp -d=postgresql
- rails g scaffold message body:text

- Use below simple css for styling in application.html.erb
   <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">

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

Now, when you add new message, the counter gets updated without page refresh.
