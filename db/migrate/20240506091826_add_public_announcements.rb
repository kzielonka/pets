class AddPublicAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :public_announcements, id: :uuid do |t|
      t.string :title, null: false
      t.string :content, null: false
      t.point :location, null: false
      t.timestamps
    end
  end
end
