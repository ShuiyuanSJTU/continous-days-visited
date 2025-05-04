# frozen_string_literal: true

::DiscourseContinousDaysVisited::Engine.routes.draw do
  constraints AdminConstraint.new do
    get "/:user_id" => "continous_days_visited#index"
    delete "/:user_id" => "continous_days_visited#destroy"
  end
end

Discourse::Application.routes.draw do
  mount ::DiscourseContinousDaysVisited::Engine, at: "/continous_days_visited"
end
