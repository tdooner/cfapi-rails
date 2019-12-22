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

ActiveRecord::Schema.define(version: 2019_12_22_225118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_objects", force: :cascade do |t|
    t.string "type"
    t.string "object_id"
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brigade_leaders", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.bigint "brigade_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brigade_id"], name: "index_brigade_leaders_on_brigade_id"
  end

  create_table "brigade_projects", force: :cascade do |t|
    t.string "name"
    t.string "code_url"
    t.string "link_url"
    t.bigint "brigade_id"
    t.index ["brigade_id"], name: "index_brigade_projects_on_brigade_id"
  end

  create_table "brigades", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_url"
    t.string "meetup_url"
    t.string "slug"
    t.index ["slug"], name: "index_brigades_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "metric_snapshots", force: :cascade do |t|
    t.string "metric_name"
    t.decimal "metric_value"
    t.datetime "created_at"
    t.string "related_object_type"
    t.bigint "related_object_id"
    t.index ["metric_name", "created_at"], name: "index_metric_snapshots_on_metric_name_and_created_at"
    t.index ["related_object_type", "related_object_id"], name: "idx_metric_snapshots_related_object"
  end

  create_table "oauth_identities", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id"
    t.json "token_hash", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "service_user_id", null: false
    t.string "service_username", null: false
    t.index ["type", "user_id"], name: "index_oauth_identities_on_type_and_user_id", unique: true
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_salesforce_account"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
