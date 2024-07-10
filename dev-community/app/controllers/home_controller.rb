class HomeController < ApplicationController
  def index
    # @users = User.all
    @users = User.limit(20).order(:created_at)
  end
end
