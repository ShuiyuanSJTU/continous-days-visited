export default function() {
  this.route("continous-days-visited", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
