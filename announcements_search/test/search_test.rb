require "minitest/autorun"
require "announcements_search"
require "announcements"
require "events_bus"

class TestAnnouncementsSearch < Minitest::Test

  def setup
    @events_bus = EventsBus.new
    @announcements_search = AnnouncementsSearch.new
    @announcements_search.subscribe(@events_bus)
  end

  def test_search_with_no_announcements
    announcements = @announcements_search.search
    assert_equal 0, announcements.size
  end

  def test_search_with_one_announcement
    @events_bus.publish({
      type: "AnnouncementPublished",
      payload: {
        "id" => "id-1234",
        "title" => "title",
        "content" => "content",
        "location" => { "latitude" => 4, "longitude" => 3 },
      }
    })
    announcements = @announcements_search.search
    assert_equal 1, announcements.size
    assert_equal "id-1234", announcements[0].id
    assert_equal "title", announcements[0].title
    assert_equal "content", announcements[0].content
    assert_equal Announcements::Location.new(4, 3), announcements[0].location
  end

  def test_publishing_and_unpublishing_announcement
    announcements = @announcements_search.search
    assert_equal 0, announcements.size

    @events_bus.publish({
      type: "AnnouncementPublished",
      payload: {
        "id" => "id-1234",
        "title" => "title",
        "content" => "content",
        "location" => { "latitude" => 4, "longitude" => 3 },
      }
    })

    announcements = @announcements_search.search
    assert_equal 1, announcements.size

    @events_bus.publish({
      type: "AnnouncementUnpublished",
      payload: {
        "id" => "id-1234",
      }
    })

    announcements = @announcements_search.search
    assert_equal 0, announcements.size
  end
end

