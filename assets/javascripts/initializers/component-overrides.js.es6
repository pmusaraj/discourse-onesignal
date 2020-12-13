import { withPluginApi } from "discourse/lib/plugin-api";
import { on } from "discourse-common/utils/decorators";

export default {
  name: "onesignal-component-overrides",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      api.modifyClass("component:d-modal", {
        init() {
          this._super(...arguments);

          if (document.body.classList.contains("mobile-app-login-modal")) {
            this.set("dismissable", false);
          }
        },
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
