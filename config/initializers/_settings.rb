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

# App.wallet = "1AoZJzq5FqdJygZyG7KYkmpYZx7vMxn4cw" # John's wallet
App.wallet = "1Brt3KNoAF6ovANZG3KpybpLhnAi1kWPc9" # Luis@sci.ventures / Blockchain.info

App.currency = "BTC"

App.emails = {
  admin:      "admin@bitstars.ph",
  sales:      "support@bitstars.ph",
  support:    "support@bitstars.ph",
  accounting: "support@bitstars.ph"
}

# App.emails.support = "luis@bitmarket.ph"

App.timezone = "GMT+8"

App.max_submissions_per_day = 3

App.winner_lockout = 1.week

App.minimum_tip = 0.0001

App.minimum_withdrawal = 0.025

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
    app_id:   "838918866136762",
    secret:   "4ca317ea59738dec88264e0e8798f0fc"
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
  App.services.facebook.app_id = "836953916333257"
  App.services.facebook.secret = "e367a62ee7d6ff94c3121ab4d7b044cd"
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

App.flag_reasons = [
  { slug: :not_selfie, description: "This is not a selfie" },
  { slug: :nsfw,       description: "This contains nudity" },
  { slug: :fake,       description: "This photo is a fake" }
]
# if you add more flag reasons, don't forget to add the corresponding slugs to Photo.rb's make_flaggable call


App.charities = [
  {
    slug: "abs",
    name: "ABS CBN Foundation",
    url: "http://www.abs-cbnfoundation.com/",
    description: "Outreach programs for children, their families, the environment, and community." 
    },
  {
    slug: 'car',
    name: "Compassion and Responsibility for Animals (CARA)",
    url: "http://caraphil.org",
    description: "Formed in 2000 by a group of animal lovers determined to help the plight of the animals in the Philippines."
    },
  {
    slug: 'gk',
    name: "Gawad Kalinga",
    url: "http://www.gawadkalinga.org/",
    description: "Promotes alternative solution to housing problems in povery-striken areas."
    },
  {
    slug: "har",
    name: "Haribon Foundation",
    url: "http://haribon.org.ph",
    description: "A membership organization committed to nature conservation through community empowerment, and scientific excellence."
  },
  {
    slug: "paw",
    name: "Philippine Animal Welfare Society (PAWS)",
    url: "http://www.paws.org.ph/",
    description: "A volunteer-based non-government organization whose goal is to prevent animal cruelty through education, animal sheltering and advocacy."
    },
  {
    slug: 'prc',
    name: "Philippine National Red Cross",
    url: "http://www.redcross.org.ph/",
    description: "Provides relief assistance during times of disasters and natural calamities."
    },
  {
    slug: "wv",
    name: "World Vision Philippines",
    url: "http://worldvision.org.ph",
    description: "Works for the wellbeing of the poor through sustainable development, disaster and emergency response, and public engagement."
  },
  {
    slug: 'wwf',
    name: "Worldwide Fund for Nature (WWF)",
    url: "http://wwf.org.ph/",
    description: "Stop and reverse the accelerating degradation of the Philippine environment, and build a future in which Filipinos live in harmony with nature."
  }
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