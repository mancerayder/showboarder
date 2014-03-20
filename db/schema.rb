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

ActiveRecord::Schema.define(version: 20140320180040) do

  create_table "boards", force: true do |t|
    t.string   "name",                 default: "", null: false
    t.string   "email",                default: "", null: false
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "time_zone",            default: 0,  null: false
    t.string   "vanity_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boards", ["confirmation_token"], name: "index_boards_on_confirmation_token", unique: true
  add_index "boards", ["email"], name: "index_boards_on_email", unique: true
  add_index "boards", ["vanity_url"], name: "index_boards_on_vanity_url", unique: true

  create_table "guests", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guests", ["email"], name: "index_guests_on_email", unique: true

  create_table "user_boards", force: true do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.string   "role",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_boards", ["board_id"], name: "index_user_boards_on_board_id"
  add_index "user_boards", ["user_id", "board_id"], name: "index_user_boards_on_user_id_and_board_id", unique: true
  add_index "user_boards", ["user_id"], name: "index_user_boards_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "name"
    t.string   "image"
    t.string   "location"
    t.string   "facebook_url"
    t.integer  "timezone"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
