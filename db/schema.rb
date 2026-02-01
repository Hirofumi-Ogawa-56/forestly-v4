# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_01_31_071740) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "owner_profile_id", null: false
    t.integer "team_id"
    t.string "title"
    t.integer "status"
    t.integer "visibility_range"
    t.string "actable_type", null: false
    t.integer "actable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_room_id"
    t.boolean "can_edit", default: false, null: false
    t.integer "permission_type"
    t.boolean "allow_comment"
    t.boolean "allow_reaction"
    t.boolean "log_access"
    t.integer "parent_activity_id"
    t.index ["actable_type", "actable_id"], name: "index_activities_on_actable"
    t.index ["chat_room_id"], name: "index_activities_on_chat_room_id"
    t.index ["owner_profile_id"], name: "index_activities_on_owner_profile_id"
    t.index ["parent_activity_id"], name: "index_activities_on_parent_activity_id"
    t.index ["team_id"], name: "index_activities_on_team_id"
  end

  create_table "chat_memberships", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "chat_room_id", null: false
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_chat_memberships_on_chat_room_id"
    t.index ["profile_id"], name: "index_chat_memberships_on_profile_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "display_name"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "label"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.integer "team_role"
    t.string "profile_id"
    t.integer "status", default: 0, null: false
    t.index ["profile_id"], name: "index_profiles_on_profile_id", unique: true
    t.index ["team_id"], name: "index_profiles_on_team_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "room_memberships", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "chat_room_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_room_memberships_on_chat_room_id"
    t.index ["profile_id"], name: "index_room_memberships_on_profile_id"
  end

  create_table "room_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "edited_at"
  end

  create_table "schedule_invitations", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.integer "profile_id", null: false
    t.string "invitation_status", default: "pending", null: false
    t.string "join_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_schedule_invitations_on_profile_id"
    t.index ["schedule_id", "profile_id"], name: "index_schedule_invitations_on_schedule_id_and_profile_id", unique: true
    t.index ["schedule_id"], name: "index_schedule_invitations_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "start_at"
    t.text "describe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "end_at"
    t.string "schedule_status", default: "confirmed", null: false
  end

  create_table "social_posts", force: :cascade do |t|
    t.text "content"
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "SocialPost", null: false
    t.integer "source_post_id"
    t.index ["source_post_id"], name: "index_social_posts_on_source_post_id"
    t.index ["type"], name: "index_social_posts_on_type"
  end

  create_table "task_assignees", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_task_assignees_on_profile_id"
    t.index ["task_id"], name: "index_task_assignees_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "task_status", default: 0
    t.datetime "deadline"
    t.text "describe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_membership_requests", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "profile_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["profile_id"], name: "index_team_membership_requests_on_profile_id"
    t.index ["team_id"], name: "index_team_membership_requests_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "display_name", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "works", force: :cascade do |t|
    t.string "actable_type", null: false
    t.integer "actable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actable_type", "actable_id"], name: "index_works_on_actable"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_memberships", "chat_rooms"
  add_foreign_key "chat_memberships", "profiles"
  add_foreign_key "profiles", "teams"
  add_foreign_key "profiles", "users"
  add_foreign_key "room_memberships", "chat_rooms"
  add_foreign_key "room_memberships", "profiles"
  add_foreign_key "schedule_invitations", "profiles"
  add_foreign_key "schedule_invitations", "schedules"
  add_foreign_key "social_posts", "social_posts", column: "source_post_id"
  add_foreign_key "task_assignees", "profiles"
  add_foreign_key "task_assignees", "tasks"
  add_foreign_key "team_membership_requests", "profiles"
  add_foreign_key "team_membership_requests", "teams"
end
