App = Hashie::Mash.new

App.name = "Bitstars"
App.slug = "bitstars"
App.business_name = "Satoshi Citadel, Inc."
App.address = "Renaissance Center, 215 Salcedo St., Makati City, Philippines"
App.phone = "+63 2 843-3841"
App.tagline = "May the best selfie win!"
App.secondary_tagline = "Make money from your selfies every single day" 
App.description = ""
App.url = Rails.env.development? ? "bitstars.xxx" : "bitstars.ph"
App.email_url = "bitstars.ph"
# email domains also need to be set up in production.rb

App.wallet = "1AoZJzq5FqdJygZyG7KYkmpYZx7vMxn4cw" # John's wallet

App.currency = "BTC"

App.emails = {
  admin:      "admin@#{App.email_url}",
  sales:      "sales@#{App.email_url}",
  support:    "support@#{App.email_url}",
  accounting: "accounts@#{App.email_url}",
  noreply:    "no-reply@#{App.email_url}"
}

App.timezone = "GMT+8"

App.max_submissions_per_day = 3

App.winner_lockout = 1.week

App.minimum_tip = 0.0001

App.daily_prize_in_php = 500

App.transaction_fee_percentage = 0.01

App.services = {
  :open_exchange => {
    app_id: "1ba3c1a8bab6490daf5dcc7dbc3149ec"
  },
  :ses => {
    access_key:         "",
    secret_access_key:  ""
  },
  :instagram => {
    client_id:      "825e0611bba34fa38931a071e9e9072e",
    client_secret:  "0459374440b04064a32f645dbc3594d4"
  },
  :mailchimp => {
    access_key: "",
    list_id:    ""
  },
  :facebook => {
    username: "",
    app_id:   "836953916333257",
    secret:   "e367a62ee7d6ff94c3121ab4d7b044cd"
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

if Rails.env.production?
  App.services.instagram.client_id="b55465b7d8c7436ba963ecfcf793f8f2"
  App.services.instagram.client_secret="22513346373a4321a3d328b943e1ee7a"
end

App.currencies = [
  { symbol: "&#3647;", slug: "BTC", name: "Bitcoin" },
  { symbol: "&#8369;", slug: "PHP", name: "Philippine Peso" },
  { symbol: "US$",       slug: "USD", name: "US Dollar" },
  { symbol: "CA$",       slug: "CAD", name: "Canadian Dollar" },
  { symbol: "&#165;",  slug: "JPY", name: "Japanese Yen" },
  { symbol: "AU$",       slug: "AUD", name: "Australian Dollar" },
  { symbol: "&pound;", slug: "GBP", name: "Pound Sterling" },
  { symbol: "RM",      slug: "MYR", name: "Malaysian Ringgit" },
  { symbol: "SG$",      slug: "SGD", name: "Singaporean Dollar" },
  { symbol: "HK$",     slug: "HKD", name: "Hong Kong Dollar" }
]

# johnbailon
# yo_leroy
# tonyotonio
# calspec
# sabinalopez
# hashgarcia
# milk_n_lipstick
# clockworkchico
# oscarbicadaiii
# kassypajarillo
# bunsovercarrots

# username: thecourtjester001
# password: igram123@

# username: theredqueen0001
# password: igram123@

# username: thewhitequeen001
# password: igram123@