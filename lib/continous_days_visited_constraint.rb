class ContinousDaysVisitedConstraint
  def matches?(request)
    SiteSetting.continous_days_visited_enabled
  end
end
