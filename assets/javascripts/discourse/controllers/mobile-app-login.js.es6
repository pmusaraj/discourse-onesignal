import Controller from "@ember/controller";
import { defaultHomepage } from "discourse/lib/utilities";
import DiscourseURL from "discourse/lib/url";

export default Controller.extend({
  init() {
    this._super(...arguments);

    if (this.currentUser) {
      DiscourseURL.redirectTo(`/${defaultHomepage()}`);
    }
  },
});
