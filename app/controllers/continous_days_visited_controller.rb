# frozen_string_literal: true

class ContinousDaysVisitedController < ::ApplicationController
  requires_plugin ::DiscourseContinousDaysVisited::PLUGIN_NAME

  def index
    user = User.find_by(id: params[:user_id])
    if user.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end
    render json: {
             user_id: user.id,
             username: user.username,
             continous_days_visited:
               ::DiscourseContinousDaysVisited::ContinousDaysVisited.continous_days_visited(user),
           }
  end

  def destroy
    user = User.find_by(id: params[:user_id])
    if user.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end
    ::DiscourseContinousDaysVisited::ContinousDaysVisited.clean_stored_continous_days_visited(user)
    render json: { success: "Cleaned continous days visited" }
  end
end
