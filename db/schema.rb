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

ActiveRecord::Schema[7.1].define(version: 2026_05_02_121504) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "lead_id"
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_activity_logs_on_lead_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
    t.index ["workspace_id", "created_at"], name: "index_activity_logs_on_workspace_id_and_created_at"
    t.index ["workspace_id"], name: "index_activity_logs_on_workspace_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "assigned_to_id"
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.string "company_name"
    t.string "source"
    t.string "status", default: "New", null: false
    t.decimal "estimated_value", precision: 12, scale: 2, default: "0.0"
    t.string "priority", default: "Medium", null: false
    t.datetime "next_follow_up_at"
    t.text "notes_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_leads_on_assigned_to_id"
    t.index ["workspace_id", "next_follow_up_at"], name: "index_leads_on_workspace_id_and_next_follow_up_at"
    t.index ["workspace_id", "status"], name: "index_leads_on_workspace_id_and_status"
    t.index ["workspace_id"], name: "index_leads_on_workspace_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_notes_on_lead_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "staff", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.string "business_type"
    t.string "plan", default: "Growth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "activity_logs", "leads"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "activity_logs", "workspaces"
  add_foreign_key "leads", "users", column: "assigned_to_id"
  add_foreign_key "leads", "workspaces"
  add_foreign_key "notes", "leads"
  add_foreign_key "notes", "users"
  add_foreign_key "users", "workspaces"
end
