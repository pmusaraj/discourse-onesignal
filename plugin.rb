# name: discourse-onesignal
# about: Push notifications via the OneSignal API. 
# version: 1.0
# authors: pmusaraj
# url: https://github.com/pmusaraj/discourse-onesignal

after_initialize do
  if SiteSetting.onesignal_push_enabled
    ONESIGNALAPI = 'https://onesignal.com/api/v1/notifications'

    DiscourseEvent.on(:post_notification_alert) do |user, payload|

      if SiteSetting.onesignal_app_id.nil? || SiteSetting.onesignal_app_id.empty?
          Rails.logger.warn('OneSignal App ID is missing')
          return
      end
      if SiteSetting.onesignal_rest_api_key.nil? || SiteSetting.onesignal_rest_api_key.empty?
          Rails.logger.warn('OneSignal REST API Key is missing')
          return
      end

      clients = user.user_api_keys
          .where("('push' = ANY(scopes) OR 'notifications' = ANY(scopes)) AND push_url IS NOT NULL AND position(push_url in ?) > 0 AND revoked_at IS NULL",
                    ONESIGNALAPI)
          .pluck(:client_id, :push_url)

      if clients.length > 0
        Jobs.enqueue(:onesignal_pushnotification, clients: clients, payload: payload, username: user.username)
      else 
        Rails.logger.error("#{user.to_yaml}")
      end

    end

    module ::Jobs
      class OnesignalPushnotification < Jobs::Base
        def execute(args)
          payload = args["payload"]

          params = {
            "app_id" => SiteSetting.onesignal_app_id, 
            "contents" => {"en" => "#{payload[:username]}: #{payload[:excerpt]}"},
            "headings" => {"en" => payload[:topic_title]},
            "data" => {"discourse_url" => payload[:post_url]},
            "filters" => [
                {"field": "tag", "key": "username", "relation": "=", "value": args["username"]}, 
              ]
          }

          uri = URI.parse(ONESIGNALAPI)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'

          request = Net::HTTP::Post.new(uri.path,
              'Content-Type'  => 'application/json;charset=utf-8',
              'Authorization' => "Basic #{SiteSetting.onesignal_rest_api_key}")
          request.body = params.as_json.to_json
          response = http.request(request) 

          case response
          when Net::HTTPSuccess then
            Rails.logger.info("Push Notification sent via OneSignal")
          else
            Rails.logger.error("Push Notification Error: (uri) #{uri} - (response) #{response.to_yaml}")
          end

        end
      end
    end

  end
end
