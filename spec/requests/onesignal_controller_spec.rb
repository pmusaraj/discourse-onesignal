require 'rails_helper'

describe DiscourseOnesignal::OnesignalController do

  it 'requires params' do
    sign_in(Fabricate(:user))

    post "/onesignal/subscribe.json", params: {
      token: "atoken"
    }

    expect(response.status).to eq(400)
    expect(response.body).to include('param is missing')
  end

  it 'works!' do
    sign_in(Fabricate(:user))

    post "/onesignal/subscribe.json", params: {
      token: "a token",
      application_name: "My App",
      platform: "ios"
    }

    expect(response.status).to eq(200)
    expect(OnesignalSubscription.last.device_token).to eq('a token')
  end

end
