import { later, next } from "@ember/runloop";
import { on } from "@ember/object/evented";
import Route from "@ember/routing/route";

export default Route.extend({
  afterModel(model, transition) {
    if (!this.currentUser) {
      next(() => transition.send("showLogin"));
    } else {
      next(() => this.transitionTo("discovery.latest"));
    }
  },
  addBodyClass: on("activate", function () {
    if (!this.currentUser) {
      document.body.classList.add("mobile-app-login-modal");
    }
  }),
  removeBodyClass: on("deactivate", function () {
    if (!this.currentUser) {
      later(
        () => document.body.classList.remove("mobile-app-login-modal"),
        300
      );
    }
  }),
});
