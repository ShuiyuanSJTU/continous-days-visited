import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("continous-days-visited", { loggedIn: true });

test("continous-days-visited works", async assert => {
  await visit("/admin/plugins/continous-days-visited");

  assert.ok(false, "it shows the continous-days-visited button");
});
