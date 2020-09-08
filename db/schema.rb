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

ActiveRecord::Schema.define(version: 2020_09_08_081437) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "novel_series", force: :cascade do |t|
    t.string "series_title", null: false
    t.text "series_description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author"
    t.boolean "release", default: false, null: false
    t.index ["user_id"], name: "index_novel_series_on_user_id"
  end

  create_table "novels", force: :cascade do |t|
    t.string "novel_title", null: false
    t.text "novel_description"
    t.text "novel_content", null: false
    t.string "author", null: false
    t.boolean "release", default: false, null: false
    t.bigint "user_id", null: false
    t.bigint "novel_series_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_series_id"], name: "index_novels_on_novel_series_id"
    t.index ["user_id"], name: "index_novels_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "account_id", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.boolean "admin", default: false, null: false
    t.text "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "novel_series", "users"
  add_foreign_key "novels", "novel_series"
  add_foreign_key "novels", "users"
end
