# README
Building a developers community application in Rails 7.2


# Install Twitter Bootstrap and Add Header-Footer partials
Since we have `cssbundling-rails` gem. Run `rails css:install:bootstrap` 

Running this command will generate app/assets/builds/applications.css containing all bootstrap's CSS properties. Also stylesheets/application.css becomes stylesheets/application.bootstrap.scss

If it happens, Bootstrap is successfully installed in our project. Since bootstrap has dependency on popper js, we need to pin it, 

`./bin/importmap pin boostrap` command will add below two lines in config/importmap.rb 
pin "bootstrap" # @5.3.3
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
