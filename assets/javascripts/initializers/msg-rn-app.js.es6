import { ajax } from "discourse/lib/ajax";
import { postRNWebviewMessage } from "discourse/lib/utilities";
import User from "discourse/models/user";

export default {
  name: "msg-rn-app",
  after: "inject-objects",

  initialize(container) {
    const currentUser = container.lookup("current-user:main");
    const capabilities = container.lookup("capabilities:main");

    if (capabilities.isAppWebview && currentUser) {
      postRNWebviewMessage("currentUsername", currentUser.username);
    }

    // called by webview
    window.DiscourseOnesignal = {
      subscribeDeviceToken(token, platform, application_name) {
        ajax("/onesignal/subscribe.json", {
          type: "POST",
          data: {
            token: token,
            platform: platform,
            application_name: application_name,
          },
        }).then((result) => {
          postRNWebviewMessage("subscribedToken", result);
        });
      },
    };
  },
};
