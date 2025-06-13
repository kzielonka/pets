class CreatePins < ActiveRecord::Migration[7.1]
  def change
    create_table :pins, id: false do |t|
      t.uuid :announcement_id, null: false, index: true, primary_key: true
      t.decimal :latitude, null: false
      t.decimal :longitude, null: false
    end
  end
end 
