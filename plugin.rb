# frozen_string_literal: true

# name: continous-days-visited
# about: Count number of continous days visited
# version: 1.0
# authors: chenyxuan, pangbo
# url: https://github.com/ShuiyuanSJTU/continous-days-visited

enabled_site_setting :continous_days_visited_enabled

require_relative 'app/lib/continous_days_visited'

PLUGIN_NAME ||= 'ContinousDaysVisited'.freeze

after_initialize do
  register_user_custom_field_type "continous_days_visited", :integer

  module OverrideUser
    def create_visit_record!(date, opts = {})
      result = super(date, opts)
      ContinousDaysVisited.increase_continous_days_visited(self)
      result
    end
  end
  ::User.prepend OverrideUser

  class ::UserSummarySerializer
    attribute :continous_days_visited

    def continous_days_visited
      object.continous_days_visited
    end

    def include_continous_days_visited?
      can_see_summary_stats
    end
  end

  class ::UserSummary
    def continous_days_visited
      ContinousDaysVisited.continous_days_visited(@user)
    end
  end

  module ::DiscourseContinousDaysVisited
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace ::DiscourseContinousDaysVisited
    end
    
    class ContinousDaysVisitedController < ::ApplicationController
      def index
        user = User.find_by(id: params[:user_id])
        if user.nil?
          render json: { error: "User not found" }, status: :not_found
          return
        end
        render json: { 
          user_id: user.id,
          username: user.username,
          continous_days_visited: ContinousDaysVisited.continous_days_visited(user) 
        }
      end

      def destroy
        user = User.find_by(id: params[:user_id])
        if user.nil?
          render json: { error: "User not found" }, status: :not_found
          return
        end
        ContinousDaysVisited.clean_stored_continous_days_visited(user)
        render json: { success: "Cleaned continous days visited" }
      end
    end

    Discourse::Application.routes.append { mount Engine, at: "/continous_days_visited" }

    Engine.routes.draw do
      constraints AdminConstraint.new do
        get "/:user_id" => "continous_days_visited#index"
        delete "/:user_id" => "continous_days_visited#destroy"
      end
    end
  end
end
