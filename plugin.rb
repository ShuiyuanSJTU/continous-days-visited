# frozen_string_literal: true

# name: continous-days-visited
# about: Count number of continous days visited
# version: 0.1
# authors: chenyxuan
# url: https://github.com/chenyxuan

register_asset 'stylesheets/common/continous-days-visited.scss'
register_asset 'stylesheets/desktop/continous-days-visited.scss', :desktop
register_asset 'stylesheets/mobile/continous-days-visited.scss', :mobile

enabled_site_setting :continous_days_visited_enabled

PLUGIN_NAME ||= 'ContinousDaysVisited'

load File.expand_path('lib/continous-days-visited/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb
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
    def days_visited_recently(time_period)
      @user.user_visits.where("visited_at > ?", time_period.days.ago).count
    end
    
    def continous_days_visited
      l, r = 0, days_visited_recently(36500) + 1
      while l + 1 != r do
        mid = (l + r) >> 1
        if days_visited_recently(mid) >= mid
          l = mid
        else
          r = mid
        end
      end
      l    
    end
  end
end
