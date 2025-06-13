class AddGistIndexOnPublicAnnouncementsLocation < ActiveRecord::Migration[7.1]
  def up
    add_index :public_announcements, :location, using: :gist
  end
end 