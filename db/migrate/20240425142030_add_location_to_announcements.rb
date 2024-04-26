class AddLocationToAnnouncements < ActiveRecord::Migration[7.1]
  def change
    add_column :announcements, :latitude, :decimal
    add_column :announcements, :longitude, :decimal
  end
end
