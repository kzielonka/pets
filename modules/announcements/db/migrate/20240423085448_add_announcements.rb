class AddAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements, id: :uuid do |t|
      t.boolean :draft, null: false
      t.string :owner_id, null: false, index: true
      t.string :title, null: true
      t.text :content, null: true
      t.timestamps
    end
  end
end 