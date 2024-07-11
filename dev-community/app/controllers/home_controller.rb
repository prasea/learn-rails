class HomeController < ApplicationController
  def index
    # @users = User.all
    @q = User.ransack(params[:q])
    @users = @q.result().limit(20).order(:created_at)
  end
end
