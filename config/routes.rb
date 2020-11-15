require_dependency "continous_days_visited_constraint"

ContinousDaysVisited::Engine.routes.draw do
  get "/" => "continous_days_visited#index", constraints: ContinousDaysVisitedConstraint.new
  get "/actions" => "actions#index", constraints: ContinousDaysVisitedConstraint.new
  get "/actions/:id" => "actions#show", constraints: ContinousDaysVisitedConstraint.new
end
