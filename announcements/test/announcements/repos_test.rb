require "minitest/autorun"
require "announcements"

class Announcements
  module Repos
    module ContractTests
      def test_saves_and_finds_announcement
        announcement = Announcement.draft_with_random_id
          .change_title(:system, "title")
          .change_content(:system, "content")
        @repo.save(announcement)
        found_announcement = @repo.find(announcement.id)
        assert_equal "title", found_announcement.title
        assert_equal "content", found_announcement.content
      end

      def test_finds_announcement_by_user
        announcement1 = Announcement.draft_with_random_id
          .change_title(:system, "title1")
          .assign_owner("owner-1")
        announcement2 = Announcement.draft_with_random_id
          .change_title(:system, "title2")
          .assign_owner("owner-1")
        announcement3 = Announcement.draft_with_random_id
          .change_title(:system, "title3")
          .assign_owner("owner-2")

        @repo.save(announcement1)
        @repo.save(announcement2)
        @repo.save(announcement3)

        found_announcements = @repo.find_by_user(Users.build("owner-1"))
        assert found_announcements.size == 2, "returns 2 announcements"
        assert_equal ["title1", "title2"], found_announcements.map(&:title).sort()

        found_announcements = @repo.find_by_user(Users.build("owner-2"))
        assert found_announcements.size == 1, "returns 1 announcement"
        assert_equal ["title3"], found_announcements.map(&:title).sort()

        found_announcements = @repo.find_by_user(Users.build("owner-3"))
        assert found_announcements.size == 0, "returns no announcements"
      end

      def test_announcement_update
        announcement = Announcement.draft_with_random_id
          .change_title(:system, "title1")
          .change_content(:system, "content1")

        @repo.save(announcement)
        found_announcement = @repo.find(announcement.id)
        assert_equal "title1", found_announcement.title
        assert_equal "content1", found_announcement.content

        announcement.change_title(:system, "title2").change_content(:system, "content2")

        @repo.save(announcement)
        found_announcement = @repo.find(announcement.id)
        assert_equal "title2", found_announcement.title
        assert_equal "content2", found_announcement.content
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
        # test_db_url = String(ENV["TEST_DATABASE_URL"])
        # raise "Please set TEST_DATABASE_URL env" if test_db_url == ""
        # ActiveRecord::Base.establish_connection(test_db_url) # adapter: "sqlite3", database: "../storage/development.sqlite3")
        ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "../storage/development.sqlite3")

        ActiveRecord::Base.connection.execute("DELETE FROM announcements;")
        @repo = Repos.build(:active_record)
      end
    end
  end
end
