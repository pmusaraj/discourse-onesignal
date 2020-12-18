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

  it 'replaces record when switching users on device' do
    prevuser = Fabricate(:user)
    current_user = Fabricate(:user)
    token = "sometoken"

    OnesignalSubscription.find_or_create_by(
      user_id: prevuser.id,
      device_token: token,
      application_name: "My App",
      platform: "android",
    )

    sign_in(current_user)

    post "/onesignal/subscribe.json", params: {
      token: token,
      application_name: "My App",
      platform: "ios"
    }

    expect(response.status).to eq(200)
    expect(OnesignalSubscription.last.device_token).to eq(token)
    expect(OnesignalSubscription.last.user_id).to eq(current_user.id)
  end
end
