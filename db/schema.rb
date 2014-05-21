# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140521080310) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currency_exchange_rates", force: true do |t|
    t.string   "currency",   default: "USD"
    t.float    "rate",       default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flaggings", force: true do |t|
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.string   "flagger_type"
    t.integer  "flagger_id"
    t.string   "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flaggings", ["flag", "flaggable_type", "flaggable_id"], name: "index_flaggings_on_flag_and_flaggable_type_and_flaggable_id", using: :btree
  add_index "flaggings", ["flag", "flagger_type", "flagger_id", "flaggable_type", "flaggable_id"], name: "access_flag_flaggings", using: :btree
  add_index "flaggings", ["flaggable_type", "flaggable_id"], name: "index_flaggings_on_flaggable_type_and_flaggable_id", using: :btree
  add_index "flaggings", ["flagger_type", "flagger_id", "flaggable_type", "flaggable_id"], name: "access_flaggings", using: :btree

  create_table "likes", force: true do |t|
    t.integer  "photo_id"
    t.integer  "user_id"
    t.boolean  "disqualified", default: false
    t.datetime "created_at"
  end

  add_index "likes", ["photo_id", "created_at"], name: "index_daily_likes", using: :btree
  add_index "likes", ["photo_id", "user_id"], name: "index_likes_on_user_photos", using: :btree

  create_table "photos", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "original_id"
    t.text     "description"
    t.text     "images"
    t.integer  "num_likes",    default: 0
    t.integer  "num_views",    default: 0
    t.integer  "num_tips",     default: 0
    t.boolean  "featured",     default: false
    t.boolean  "winner",       default: false
    t.boolean  "disqualified", default: false
    t.boolean  "eligible",     default: true
    t.datetime "entered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "nsfw",         default: false
  end

  add_index "photos", ["nsfw"], name: "index_photos_on_nsfw", using: :btree
  add_index "photos", ["user_id", "provider", "original_id"], name: "index_photos_on_original_provider_id", using: :btree
  add_index "photos", ["user_id"], name: "index_photos_on_user_id", using: :btree
  add_index "photos", ["winner", "created_at"], name: "index_photos_on_daily_winner", using: :btree

  create_table "prizes", force: true do |t|
    t.integer  "user_id"
    t.integer  "photo_id"
    t.float    "amount_in_sats"
    t.boolean  "revoked",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prizes", ["user_id", "photo_id"], name: "index_prizes_on_user_id_and_photo_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tables", force: true do |t|
  end

  create_table "tip_payments", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "tip_id"
    t.text     "payment_details"
    t.float    "original_amount_in_sats"
    t.float    "final_amount_in_sats"
    t.float    "transaction_fee"
    t.boolean  "paid_out"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_hash"
  end

  add_index "tip_payments", ["recipient_id", "tip_id"], name: "index_tip_payments_on_recipient_id_and_tip_id", using: :btree
  add_index "tip_payments", ["sender_id", "tip_id"], name: "index_tip_payments_on_sender_id_and_tip_id", using: :btree
  add_index "tip_payments", ["tip_id"], name: "index_tip_payments_on_tip_id", using: :btree
  add_index "tip_payments", ["transaction_hash"], name: "index_tip_payments_on_transaction_hash", using: :btree

  create_table "tips", force: true do |t|
    t.integer  "photo_id"
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.float    "amount_in_btc",         default: 0.0
    t.datetime "created_at"
    t.string   "invoice_address"
    t.boolean  "paid",                  default: false
    t.float    "actual_amount_in_sats", default: 0.0
    t.string   "message"
    t.integer  "status",                default: 0
  end

  add_index "tips", ["invoice_address"], name: "index_tips_on_invoice_address", using: :btree
  add_index "tips", ["photo_id", "recipient_id", "sender_id"], name: "index_tips_on_transaction", using: :btree
  add_index "tips", ["photo_id"], name: "index_tips_on_photo", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "email",                  default: "",    null: false
    t.string   "avatar"
    t.date     "birthday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.string   "website"
    t.string   "gender"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "wallet_address"
    t.text     "bio"
    t.text     "counts"
    t.boolean  "banned",                 default: false
    t.datetime "banned_at"
    t.boolean  "has_won",                default: false
    t.boolean  "eligible",               default: true
    t.datetime "last_won_on"
    t.float    "total_tips",             default: 0.0
    t.float    "total_winnings",         default: 0.0
    t.float    "total_earnings",         default: 0.0
    t.string   "slug"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "country"
    t.string   "postal_code"
    t.boolean  "payout_to_charity",      default: false
    t.text     "charity",                default: "t"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["payout_to_charity"], name: "index_users_on_payout_to_charity", using: :btree
  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree
  add_index "users", ["refresh_token"], name: "index_users_on_refresh_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["wallet_address"], name: "index_users_on_wallet_address", using: :btree

end
