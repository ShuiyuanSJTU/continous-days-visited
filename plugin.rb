# frozen_string_literal: true

# name: continous-days-visited
# about: Count number of continous days visited
# version: 0.1
# authors: chenyxuan
# url: https://github.com/ShuiyuanSJTU/continous-days-visited

enabled_site_setting :continous_days_visited_enabled

require_relative 'app/lib/continous_days_visited'

PLUGIN_NAME ||= 'ContinousDaysVisited'

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
end
