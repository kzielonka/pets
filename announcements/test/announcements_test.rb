require "minitest/autorun"
require "announcements"

class TestMeme < Minitest::Test
  def setup
    @announcements = Announcements.new
  end

  def test_draft_announcement_is_not_public
    announcement = @announcements.add_new_draft("creator_id")
    result = @announcements.fetch_public(announcement.id)
    assert result.not_found?
  end

  def test_announcement_publishing
    announcement = @announcements.add_new_draft("creator_id")
    id = announcement.id
    @announcements.update_title(Announcements::SYSTEM_USER, id, "title") 
    @announcements.update_content(Announcements::SYSTEM_USER, id, "content") 
    @announcements.publish(Announcements::SYSTEM_USER, id)

    result = @announcements.fetch_public(announcement.id)
    assert !result.not_found?
    assert_equal "title", result.title
    assert_equal "content", result.content
  end
end
