require "minitest/autorun"
require "announcements_search"

class AnnouncementsSearch
  module Repose
    module ContractTests
      def test_saves_and_finds_announcement
        announcement = Announcement.blank("id")
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.zero)
        @repo.save(announcement)
        announcements = @repo.search
        assert_equal 1, announcements.size
      end

      def test_orders_announcements_by_nearest_location
        announcement1 = Announcement.blank("id1")
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.new(2, 2))
        @repo.save(announcement1)

        announcement2 = Announcement.blank("id2")
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.new(3, 3))
        @repo.save(announcement2)

        announcement3 = Announcement.blank("id3")
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.new(1, 1))
        @repo.save(announcement3)

        announcements = @repo.search(Announcements::Location.zero)
        assert_equal 3, announcements.size
        assert_equal "id3", announcements[0].id
        assert_equal "id1", announcements[1].id
        assert_equal "id2", announcements[2].id
      end
    end

    class TestInMemoryRepo < Minitest::Test
      include ContractTests

      def setup
        @repo = Repos.build(:in_memory)
      end
    end
  end
end
