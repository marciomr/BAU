# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101211122611) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "editor"
    t.string   "city"
    t.string   "country"
    t.integer  "year"
    t.string   "language"
    t.text     "description"
    t.string   "collection"
    t.string   "cdd"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",       :default => true, :null => false
    t.string   "pdflink"
    t.string   "imglink"
    t.string   "subject"
    t.integer  "page_number"
    t.integer  "tombo"
    t.integer  "volume"
    t.string   "subtitle"
    t.string   "isbn"
  end

  create_table "tags", :force => true do |t|
    t.string   "title"
    t.integer  "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
