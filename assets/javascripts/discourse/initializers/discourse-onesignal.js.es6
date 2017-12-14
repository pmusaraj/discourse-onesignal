Discourse.Route.reopen({
    activate: function() {
        this._super();
        Em.run.next(function(){insertNavigationConditionally();});
    }
});

function insertNavigationConditionally() {
  // send callback to reactNative if user is logged in
  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.reactNative &&
    Discourse.User.current()) {
    window.webkit.messageHandlers.reactNative.postMessage({username: true });
  }
}

export default {
  name: 'discourse-onesignal',
  initialize() {}
};
