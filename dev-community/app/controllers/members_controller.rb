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
end
