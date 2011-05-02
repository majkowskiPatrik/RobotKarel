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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110407090431) do

  create_table "actors", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.binary   "source_code"
    t.binary   "static_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", :force => true do |t|
    t.string   "name"
    t.binary   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simulation_steps", :force => true do |t|
    t.integer  "simulation_id"
    t.binary   "data_json"
    t.integer  "step_no"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simulations", :force => true do |t|
    t.string   "name"
    t.binary   "map_json"
    t.binary   "actors_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
