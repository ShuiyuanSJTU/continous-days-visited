import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  exists,
} from "discourse/tests/helpers/qunit-helpers";

acceptance("User Profile - Summary", function (needs) {
  needs.pretender((server, helper) => {
    server.get("/u/eviltrout/summary.json", () => {
      return helper.response(200, {
        user_summary: {
          likes_given: 1,
          likes_received: 2,
          topics_entered: 3,
          posts_read_count: 4,
          days_visited: 5,
          topic_count: 6,
          post_count: 7,
          time_read: 100000,
          recent_time_read: 1000,
          bookmark_count: 0,
          can_see_summary_stats: true,
          topic_ids: [1234],
          replies: [{ topic_id: 1234 }],
          links: [{ topic_id: 1234, url: "https://eviltrout.com" }],
          most_replied_to_users: [{ id: 333 }],
          most_liked_by_users: [{ id: 333 }],
          most_liked_users: [{ id: 333 }],
          badges: [{ badge_id: 444 }],
          top_categories: [
            {
              id: 1,
              name: "bug",
              color: "e9dd00",
              text_color: "000000",
              slug: "bug",
              read_restricted: false,
              parent_category_id: null,
              topic_count: 1,
              post_count: 1,
            },
          ],
        },
        badges: [{ id: 444, count: 1 }],
        topics: [{ id: 1234, title: "cool title", slug: "cool-title" }],
      });
    });
  });

  needs.settings({ continous_days_visited_enabled: true });

  test("Viewing Summary", async function (assert) {
    await visit("/u/eviltrout/summary");

    assert.ok(exists(".user_summary_continous_days_visited"), "continous days visited");
  });
});