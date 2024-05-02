require "minitest/autorun"
require "announcements_search"
require "announcements"

class TestAnnouncementsSearch < Minitest::Test

  def setup
    @announcements_search = AnnouncementsSearch.new
  end

  def test_search_with_no_announcements
    announcements = @announcements_search.search
    assert_equal 0, announcements.size
  end

  def test_search_with_one_announcement
    @announcements_search.handle_new_published_announcement(
      id: "id-1234",
      title: "title",
      content: "content",
      location: Announcements::Location.new(4, 3)
    )
    announcements = @announcements_search.search
    assert_equal 1, announcements.size
    assert_equal "id-1234", announcements[0].id
    assert_equal "title", announcements[0].title
    assert_equal "content", announcements[0].content
    assert_equal Announcements::Location.new(4, 3), announcements[0].location
  end
end

