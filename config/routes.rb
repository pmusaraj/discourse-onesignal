DiscourseOnesignal::Engine.routes.draw do
  post '/subscribe' => "onesignal#subscribe"
  get '/app-login' => "onesignal#app_login", format: :html
end
