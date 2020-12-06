import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "onesignal-component-overrides",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      api.modifyClass("component:d-modal", {
        mouseDown(e) {
          if (document.body.classList.contains("mobile-app-login-modal")) {
            return;
          }

          this._super(...arguments);
        },
      });
    });
  },
};
