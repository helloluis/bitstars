App = Hashie::Mash.new

App.name = "Viviem Pearls"
App.slug = "pearls"
App.business_name = "Viviem Pearls, Inc."
App.address = "Sydney, Australia"
App.phone = "+61 2 8001 1900"

App.url = Rails.env.development? ? "localhost:3000" : "pearlsau.herokuapp.com"
# email domains also need to be set up in production.rb

App.analytics = {
  gaecommerce: true,
  mixpanel:    false,
  crazyegg:    false,
  upsellit:    false,
  trada:       false,
  adroll:      false,
  linkshare:   false
}

App.allow_guest_purchases = true

App.services = {
  :s3 => {
    access_key:         "AKIAJG3EHF3WWQKTXUBA",
    secret_access_key:  "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"    
  },
  :ses => {
    access_key:         "",
    secret_access_key:  ""
  },
  :mailchimp => {
    access_key: "",
    list_id:    ""
  },
  :facebook => {
    username: "",
    app_id:   "",
    secret:   ""
  },
  :twitter => {
    username: "",
    app_id:   "",
    secret:   ""
  },
  :pinterest => {
    username: ""
  },
  :googleplus => {
    username: "",
    app_id:   "",
    secret:   ""
  },
  :stripe => {}
}

if Rails.env.production?
  App.services.s3.bucket = "lmk-#{App.slug}-production"
else
  App.services.s3.bucket = "lmk-#{App.slug}-development"
end

App.emails = {
  admin:      "admin@#{App.url}",
  sales:      "sales@#{App.url}",
  support:    "support@#{App.url}",
  accounting: "accounts@#{App.url}",
  noreply:    "no-reply@#{App.url}"
}