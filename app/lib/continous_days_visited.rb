class ContinousDaysVisited
    def initialize(user)
        @user = user
    end

    def days_visited_recently(time_period)
        @user.user_visits\
            .where("visited_at > ? and posts_read > 0", time_period.days.ago.to_date).count
    end

    def visited_yesterday?
        @user.user_visits\
            .find_by("visited_at = ? and posts_read > 0", 1.days.ago.to_date).present?
    end

    def recompute_continous_days_visited
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
    end

    def reset_continous_days_visited
        save_continous_days_visited(0)
    end

    def continous_days_visited
        stored_days_visited = @user.custom_fields[:continous_days_visited]&.to_i
        if stored_days_visited.nil?
            return recompute_and_store
        else
            if stored_days_visited == 0
                return 0
            elsif !visited_yesterday?
                reset_continous_days_visited
                return 0
            else
                return stored_days_visited
            end
        end
    end

    def increase_continous_days_visited
        stored_days_visited = @user.custom_fields[:continous_days_visited]&.to_i
        if stored_days_visited.nil?
            return recompute_and_store
        else
            if !visited_yesterday?
                return save_continous_days_visited(1)
            else
                return save_continous_days_visited(stored_days_visited + 1)
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