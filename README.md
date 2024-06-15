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
