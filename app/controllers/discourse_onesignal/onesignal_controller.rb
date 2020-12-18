# frozen_string_literal: true

module DiscourseOnesignal
  class     OnesignalController < ::ApplicationController
    requires_plugin DiscourseOnesignal

    before_action :ensure_logged_in, except: [:app_login]

    def subscribe
      token = params.require(:token)
      application_name = params.require(:application_name)
      platform = params.require(:platform)

      if ["ios", "android"].exclude?(platform)
        raise Discourse::InvalidParameters, "Platform parameter should be ios or android."
      end

      # clear any records of this device linked to other users
      OnesignalSubscription.where(device_token: token).where.not(user_id: current_user.id).destroy_all

      record = OnesignalSubscription.find_or_create_by(
        user_id: current_user.id,
        device_token: token,
        application_name: application_name,
        platform: platform,
      )

      render json: record
    end

    def app_login
      render json: success_json
    end
  end
end
