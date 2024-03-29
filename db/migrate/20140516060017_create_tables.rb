class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      
      create_table "sessions", force: true do |t|
        t.string   "session_id", null: false
        t.text     "data"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      create_table "users", force: true do |t|
        t.string   "first_name"
        t.string   "last_name"
        t.string   "full_name"
        t.string   "email",                  default: "", null: false
        t.string   "avatar"
        t.date     "birthday"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "encrypted_password",     default: "", null: false
        t.string   "reset_password_token"
        t.datetime "reset_password_sent_at"
        t.datetime "remember_created_at"
        t.integer  "sign_in_count",          default: 0,  null: false
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
        t.string   "tip_address"
        t.text     "bio"
        t.text     "counts"
        t.boolean  "banned",                  default: false
        t.datetime "banned_at"
        t.boolean  "has_won",                 default: false
        t.boolean  "eligible",                default: true
        t.datetime "last_won_on"
        t.float    "total_tips",              default: 0.0
        t.float    "total_winnings",          default: 0.0
        t.float    "total_earnings",          default: 0.0
      end

      add_index "users", ["access_token"], name: "index_users_on_access_token", using: :btree
      add_index "users", ["refresh_token"], name: "index_users_on_refresh_token", using: :btree
      add_index "users", ["tip_address"], name: "index_users_on_tip_address", using: :btree
      add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
      add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
      add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree
      add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

      create_table "photos", force: true do |t|
        t.integer  "user_id"
        t.string   "provider"
        t.string   "original_id"
        t.text     "description"
        t.text     "images"
        t.integer  "num_likes",     default: 0
        t.integer  "num_views",     default: 0
        t.integer  "num_tips",      default: 0
        t.boolean  "featured",      default: false
        t.boolean  "winner",        default: false
        t.boolean  "disqualified",  default: false
        t.boolean  "eligible",      default: true
        t.datetime "entered_at"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "photos", ["user_id","provider","original_id"], name: "index_photos_on_original_provider_id", using: :btree
      add_index "photos", ["user_id"], name: "index_photos_on_user_id", using: :btree
      add_index "photos", ["winner","created_at"],  name: "index_photos_on_daily_winner", using: :btree

      create_table "likes", force: true do |t|
        t.integer   "photo_id"
        t.integer   "user_id"
        t.boolean   "disqualified",  default: false
        t.datetime  "created_at"
      end

      add_index "likes", ["photo_id","created_at"], name: "index_daily_likes", using: :btree
      add_index "likes", ["photo_id","user_id"], name: "index_likes_on_user_photos", using: :btree

      create_table "tips", force: true do |t|
        t.integer  "photo_id"
        t.integer  "recipient_id"
        t.integer  "sender_id"
        t.float    "amount_in_btc",   default: 0.0
        t.float    "amount_in_php",   default: 0.0
        t.float    "transaction_fee", default: 0.0
        t.datetime "created_at"
      end

      add_index "tips", ["photo_id"], name: "index_tips_on_photo", using: :btree
      add_index "tips", ["photo_id","recipient_id","sender_id"], name: "index_tips_on_transaction", using: :btree

    end
  end
end
