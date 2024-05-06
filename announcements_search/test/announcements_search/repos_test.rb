require "minitest/autorun"
require "announcements_search"

class AnnouncementsSearch
  module Repos
    module ContractTests
      def test_saves_and_finds_announcement
        announcement = Announcement.random_id
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.new(43.21, -87.432))
        @repo.save(announcement)
        announcements = @repo.search
        assert_equal 1, announcements.size
        assert_equal "title", announcements[0].title
        assert_equal "content", announcements[0].content
        assert_equal Announcements::Location.new(43.21, -87.432), announcements[0].location
      end

      def test_updates_announcement
        announcement = Announcement.random_id
          .with_title("title")
          .with_content("content") 
          .with_location(Announcements::Location.new(43.21, -87.432))
        @repo.save(announcement)

        updated_announcement = announcement
          .with_title("updated title")
          .with_content("updated content")
          .with_location(Announcements::Location.new(32.12, 43.21))
        @repo.save(updated_announcement)

        announcements = @repo.search
        assert_equal 1, announcements.size
        assert_equal "updated title", announcements[0].title
        assert_equal "updated content", announcements[0].content
        assert_equal Announcements::Location.new(32.12, 43.21), announcements[0].location
      end

      def test_orders_announcements_by_nearest_location
        announcement1 = Announcement.random_id
          .with_title("title1")
          .with_content("content") 
          .with_location(Announcements::Location.new(2, 2))
        @repo.save(announcement1)

        announcement2 = Announcement.random_id
          .with_title("title2")
          .with_content("content") 
          .with_location(Announcements::Location.new(3, 3))
        @repo.save(announcement2)

        announcement3 = Announcement.random_id
          .with_title("title3")
          .with_content("content") 
          .with_location(Announcements::Location.new(1, 1))
        @repo.save(announcement3)

        announcements = @repo.search(Announcements::Location.zero)
        assert_equal 3, announcements.size
        assert_equal "title3", announcements[0].title
        assert_equal "title1", announcements[1].title
        assert_equal "title2", announcements[2].title
      end
    end

    class TestInMemoryRepo < Minitest::Test
      include ContractTests

      def setup
        @repo = Repos.build(:in_memory)
      end
    end

    class TestActiveRecordRepo < Minitest::Test
      include ContractTests

      def setup
        test_db_url = String(ENV["TEST_DATABASE_URL"])
        raise "Please set TEST_DATABASE_URL env" if test_db_url == ""
        ActiveRecord::Base.establish_connection(
          adapter: "postgresql",
          url: test_db_url
        ) 
        ActiveRecord::Base.connection.execute("DELETE FROM public_announcements;")
        @repo = Repos.build(:active_record)
      end
    end

    class ActiveRecordRepo
      class TestOrderByLocationSql < Minitest::Test
        def test_generates_sql
          result = OrderByLocationSql.new(1, 2).sql
          assert_equal "(location <@> point(2.0, 1.0))", result
        end

        def test_rasies_error_for_invalid_latitude
          assert_raises(ArgumentError) do
            OrderByLocationSql.new("invalid", 2).sql
          end
        end

        def test_rasies_error_for_invalid_longitude
          assert_raises(ArgumentError) do
            OrderByLocationSql.new(1, "invalid").sql
          end
        end

      end
    end
  end
end
