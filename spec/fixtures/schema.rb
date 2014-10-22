ActiveRecord::Schema.define do

  create_table "dummy_classes", :force => true do |t|
    t.string "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end