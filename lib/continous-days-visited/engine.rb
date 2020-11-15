module ContinousDaysVisited
  class Engine < ::Rails::Engine
    engine_name "ContinousDaysVisited".freeze
    isolate_namespace ContinousDaysVisited

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::ContinousDaysVisited::Engine, at: "/continous-days-visited"
      end
    end
  end
end
