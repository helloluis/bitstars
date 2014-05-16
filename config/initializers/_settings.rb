App = Hashie::Mash.new

App.name = "Bitstars"
App.slug = "bitstars"
App.business_name = "Satoshi Citadel, Inc."
App.address = "Renaissance Center, 215 Salcedo St., Makati City, Philippines"
App.phone = "+63 2 843-3841"
App.tagline = "Be a star with your selfies"
App.secondary_tagline = "Make money from your selfies every single day" 
App.description = ""
App.url = Rails.env.development? ? "bitstars.xxx" : "bitstars.ph"
App.email_url = "bitstars.ph"
# email domains also need to be set up in production.rb

App.wallet = "1AoZJzq5FqdJygZyG7KYkmpYZx7vMxn4cw" # John's wallet

App.currency = "USD"

App.emails = {
  admin:      "admin@#{App.email_url}",
  sales:      "sales@#{App.email_url}",
  support:    "support@#{App.email_url}",
  accounting: "accounts@#{App.email_url}",
  noreply:    "no-reply@#{App.email_url}"
}

App.services = {
  :ses => {
    access_key:         "",
    secret_access_key:  ""
  },
  :instagram => {
    client_id:      "825e0611bba34fa38931a071e9e9072e",
    client_secret: "0459374440b04064a32f645dbc3594d4"
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
  }
}
