module DiscourseOnesignal
  class Engine < ::Rails::Engine
    engine_name "DiscourseOnesignal".freeze
    isolate_namespace DiscourseOnesignal

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseOnesignal::Engine, at: "/onesignal"
      end
    end
  end
end
