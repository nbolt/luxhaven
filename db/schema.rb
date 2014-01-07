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

ActiveRecord::Schema.define(version: 20140106011702) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "neighborhood"
    t.string   "county"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id"
    t.integer  "region_id"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "venue_id"
  end

  create_table "bookings", force: true do |t|
    t.integer  "listing_id"
    t.integer  "user_id"
    t.date     "check_in"
    t.date     "check_out"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_status"
    t.string   "transfer_status"
    t.string   "stripe_transfer_id"
    t.string   "stripe_charge_id"
    t.string   "stripe_refund_id"
    t.string   "customer_id"
  end

  create_table "cards", force: true do |t|
    t.string   "stripe_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last4"
    t.string   "fingerprint"
    t.string   "card_type"
  end

  create_table "districts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.string   "slug"
  end

  create_table "faq_sections", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faq_topics", force: true do |t|
    t.string   "title"
    t.integer  "faq_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faqs", force: true do |t|
    t.string   "question"
    t.text     "answer"
    t.integer  "faq_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feature_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feature_types", force: true do |t|
    t.integer  "feature_id"
    t.string   "color"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", force: true do |t|
    t.integer  "feature_group_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features_listings", id: false, force: true do |t|
    t.integer "feature_id"
    t.integer "listing_id"
  end

  create_table "features_rooms", id: false, force: true do |t|
    t.integer "feature_id"
    t.integer "room_id"
  end

  create_table "images", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id"
    t.integer  "room_id"
    t.string   "caption"
  end

  create_table "job_qualifications", force: true do |t|
    t.string   "text"
    t.integer  "about_id"
    t.integer  "skills_id"
    t.integer  "responsibilities_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "city"
    t.boolean  "active"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "listings", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_per_night"
    t.string   "property_type"
    t.string   "title"
    t.string   "slug"
    t.integer  "region_id"
    t.string   "search_image"
    t.integer  "accomodates_from"
    t.integer  "accomodates_to"
    t.integer  "bedrooms"
    t.integer  "baths"
    t.text     "unlisted_dates"
    t.string   "header_image"
    t.integer  "district_id"
    t.boolean  "garden"
    t.boolean  "balcony"
    t.integer  "parking"
    t.boolean  "smoking"
    t.boolean  "pets"
    t.boolean  "children"
    t.boolean  "babies"
    t.boolean  "toddlers"
    t.boolean  "tv"
    t.boolean  "temp_control"
    t.boolean  "pool"
    t.boolean  "jacuzzi"
    t.boolean  "washer"
    t.text     "search_description"
  end

  add_index "listings", ["region_id"], name: "index_listings_on_region_id", using: :btree
  add_index "listings", ["slug"], name: "index_listings_on_slug", unique: true, using: :btree

  create_table "paragraph_images", force: true do |t|
    t.integer  "paragraph_id"
    t.string   "image"
    t.string   "align",        default: "right"
    t.string   "version",      default: "side_landscape"
    t.string   "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paragraphs", force: true do |t|
    t.text     "content"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",      default: 0
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "image"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "attractions_description"
    t.text     "cafes_description"
    t.text     "nightlife_description"
    t.text     "shopping_description"
    t.text     "getting_around"
    t.text     "description"
    t.text     "tagline"
  end

  add_index "regions", ["slug"], name: "index_regions_on_slug", unique: true, using: :btree

  create_table "reservations", force: true do |t|
    t.date     "check_in"
    t.date     "check_out"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rooms", force: true do |t|
    t.integer  "listing_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "stripe_recipient"
    t.string   "last_login_from_ip_address"
    t.string   "bank_name"
    t.string   "bank_last4"
    t.string   "bank_fingerprint"
    t.string   "phone_number"
    t.boolean  "admin",                           default: false
    t.boolean  "newsletter"
  end

  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

  create_table "venues", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "venue_type"
    t.boolean  "highlight"
  end

end
