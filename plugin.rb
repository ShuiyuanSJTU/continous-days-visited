# frozen_string_literal: true

# name: continous-days-visited
# about: Count number of continous days visited
# version: 1.1
# authors: chenyxuan, pangbo
# url: https://github.com/ShuiyuanSJTU/continous-days-visited

enabled_site_setting :continous_days_visited_enabled

module ::DiscourseContinousDaysVisited
  PLUGIN_NAME = "continous-days-visited".freeze
end

Rails.autoloaders.main.push_dir(
  File.join(__dir__, "lib"),
  namespace: ::DiscourseContinousDaysVisited,
)

require_relative "lib/engine"

after_initialize do
  register_user_custom_field_type "continous_days_visited", :integer

  module ::DiscourseContinousDaysVisited
    module OverrideUser
      def create_visit_record!(date, opts = {})
        result = super(date, opts)
        if date == Date.today
          ContinousDaysVisited.increase_continous_days_visited(self)
        else
          ContinousDaysVisited.clean_stored_continous_days_visited(self)
        end
        result
      end
    end
    ::User.prepend OverrideUser

    module ::OverrideUserSummary
      def continous_days_visited
        ::DiscourseContinousDaysVisited::ContinousDaysVisited.continous_days_visited(@user)
      end
    end
    ::UserSummary.prepend OverrideUserSummary
  end

  add_to_serializer(
    :user_summary,
    :continous_days_visited,
    include_condition: -> { can_see_summary_stats },
  ) { object.continous_days_visited }
end
