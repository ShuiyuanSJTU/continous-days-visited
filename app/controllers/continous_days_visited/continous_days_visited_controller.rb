module ContinousDaysVisited
  class ContinousDaysVisitedController < ::ApplicationController
    requires_plugin ContinousDaysVisited

    before_action :ensure_logged_in

    def index
    end
  end
end
