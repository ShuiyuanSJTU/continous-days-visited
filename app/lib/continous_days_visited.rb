# frozen_string_literal: true

class ContinousDaysVisited
    def initialize(user)
        @user = user
    end

    def days_visited_recently(time_period)
        @user.user_visits\
            .where("visited_at > ?", time_period.days.ago.to_date).count
    end

    def days_visited_period(left, right)
        # including left and right, [0, right-left+1]
        @user.user_visits\
            .where("visited_at >= ? AND visited_at <= ?", \
            right.days.ago.to_date, left.days.ago.to_date).count
    end

    def visited_yesterday?
        @user.user_visits\
            .find_by("visited_at = ?", 1.days.ago.to_date).present?
    end

    def visited_today?
        @user.user_visits\
            .find_by("visited_at = ?", Time.now.to_date).present?
    end

    def recompute_continous_days_visited
        # we use binary search to find the maximum number of continous days visited (excluding today)
        # our implementation is strange, because we do not want to get 0 immediately when user did not visit today
        l, r = 0, days_visited_recently(36500) + 1
        while l + 1 != r do
            # mid always greater than l, since r > l + 1
            mid = (l + r) >> 1
            if days_visited_period(1, mid) >= mid
                l = mid
            else
                r = mid
            end
        end
        visited_today? ? l + 1 : l
    end

    def save_continous_days_visited(value)
        @user.custom_fields[:continous_days_visited] = value
        @user.save_custom_fields
        value
    end

    def recompute_and_store
        save_continous_days_visited(recompute_continous_days_visited)
    end

    def clean_stored_continous_days_visited
        save_continous_days_visited(nil)
        clean_user_summary_cache
        nil
    end

    def clean_user_summary_cache
        Discourse.cache.keys("user_summary:#{@user.id}:*").each do |key|
            # do not use Discourse.cache.delete, as keys are already normalized
            Discourse.cache.redis.del(key)
        end
    end

    def reset_continous_days_visited
        save_continous_days_visited(0)
    end

    def continous_days_visited
        stored_days_visited = @user.custom_fields[:continous_days_visited]&.to_i
        if stored_days_visited.nil?
            recompute_and_store
        else
            if stored_days_visited == 0
                # quick return to reduce db query
                0
            elsif days_visited_recently(2) == 0
                # When == 2, it means user visited yesterday and today, do nothing
                # When == 1, then
                #    1. user visited yesterday but not today, do not reset immediately, wait for tomorrow
                #    2. user visited today but not yesterday, stored value already updated when user visited today, do not reset again
                # When == 0, reset continous days visited
                reset_continous_days_visited
            else
                stored_days_visited
            end
        end
    end

    def increase_continous_days_visited
        stored_days_visited = @user.custom_fields[:continous_days_visited]&.to_i
        if stored_days_visited.nil?
            recompute_and_store
        else
            if !visited_yesterday?
                # the first day of continous days visited
                save_continous_days_visited(1)
            else
                save_continous_days_visited(stored_days_visited + 1)
            end
        end
    end

    def self.continous_days_visited(user)
        new(user).continous_days_visited
    end

    def self.clean_stored_continous_days_visited(user)
        new(user).clean_stored_continous_days_visited
    end

    def self.increase_continous_days_visited(user)
        new(user).increase_continous_days_visited
    end
end