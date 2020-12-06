import { later, next } from "@ember/runloop";
import { on } from "@ember/object/evented";
import Route from "@ember/routing/route";

export default Route.extend({
  afterModel(model, transition) {
    next(() => transition.send("showLogin"));
  },
  addBodyClass: on("activate", function () {
    document.body.classList.add("mobile-app-login-modal");
  }),
  removeBodyClass: on("deactivate", function () {
    later(() => document.body.classList.remove("mobile-app-login-modal"), 300);
  }),
});
