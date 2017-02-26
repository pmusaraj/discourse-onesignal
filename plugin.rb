# name: discourse-onesignal
# about: integrate notifications with the OneSignal API. 
# version: 1.0
# authors: pmusaraj
# url: https://github.com/pmusaraj/discourse-onesignal

after_initialize do

  DiscourseEvent.on(:post_notification_alert) do |user, payload|

    return unless SiteSetting.onesignal_push_enabled?

    if SiteSetting.onesignal_app_id.nil? || SiteSetting.onesignal_app_id.empty?
        Rails.logger.warn('OneSignal App ID is missing')
        return
    end
    if SiteSetting.onesignal_rest_api_key.nil? || SiteSetting.onesignal_rest_api_key.empty?
        Rails.logger.warn('OneSignal REST API Key is missing')
        return
    end

    oneSignalURI = 'https://onesignal.com/api/v1/notifications'
    # https://api.discourse.org/api/publish_ios

    clients = user.user_api_keys
        .where("('push' = ANY(scopes) OR 'notifications' = ANY(scopes)) AND push_url IS NOT NULL AND position(push_url in ?) > 0 AND revoked_at IS NULL",
                  oneSignalURI)
        .pluck(:client_id, :push_url, :application_name)

    return unless clients.length > 0

    Rails.logger.warn("1SIG: #{clients.to_yaml}")

		params = {
			"app_id" => SiteSetting.onesignal_app_id, 
      "contents" => {"en" => "#{payload[:username]}: #{payload[:excerpt]}"},
      "headings" => {"en" => payload[:topic_title]},
      "data" => {"discourse_url" => payload[:post_url]},
      "filters" => [
          {"field": "tag", "key": "username", "relation": "=", "value": user.username}, 
        ]
		}

		uri = URI.parse(oneSignalURI)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true if uri.scheme == 'https'

		request = Net::HTTP::Post.new(uri.path,
				'Content-Type'  => 'application/json;charset=utf-8',
				'Authorization' => "Basic #{SiteSetting.onesignal_rest_api_key}")
		request.body = params.as_json.to_json
		response = http.request(request) 

    case response
    when Net::HTTPSuccess then
      Rails.logger.info("PN message sent to OneSignal")
    else
      Rails.logger.error("#{uri}: #{response.to_yaml} - #{response.message}")
    end
  end
end
