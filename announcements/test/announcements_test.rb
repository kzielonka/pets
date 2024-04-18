require "minitest/autorun"
require "announcements"

class TestAnnouncements < Minitest::Test
  def setup
    @announcements = Announcements.new
  end

  def test_draft_is_not_public
    user = Announcements::Users::RegularUser.new("creator_id")
    announcement = @announcements.add_new_draft(user)
    result = @announcements.fetch_public(announcement.id)
    assert result.not_found?
  end

  def test_edditing
    user = Announcements::Users::RegularUser.new("creator_id")
    announcement = @announcements.add_new_draft(user)
    result = @announcements.fetch_private(:system, announcement.id)
    assert !result.not_found?
    assert result.draft?
    assert_equal "", result.title
    assert_equal "", result.content

    @announcements.update_title(:system, announcement.id, "title")
    result = @announcements.fetch_private(:system, announcement.id)
    assert !result.not_found?
    assert result.draft?
    assert_equal "title", result.title
    assert_equal "", result.content

    @announcements.update_content(:system, announcement.id, "content")
    result = @announcements.fetch_private(:system, announcement.id)
    assert !result.not_found?
    assert result.draft?
    assert_equal "title", result.title
    assert_equal "content", result.content

    @announcements.publish(:system, announcement.id)
    result = @announcements.fetch_private(:system, announcement.id)
    assert !result.not_found?
    assert !result.draft?
    assert_equal "title", result.title
    assert_equal "content", result.content
  end

  def test_publishing_with_title_and_content
    user = Announcements::Users::RegularUser.new("creator_id")
    announcement = @announcements.add_new_draft(user)
    id = announcement.id
    @announcements.update_title(:system, id, "title") 
    @announcements.update_content(:system, id, "content") 
    @announcements.publish(:system, id)

    result = @announcements.fetch_public(announcement.id)
    assert !result.not_found?
    assert_equal "title", result.title
    assert_equal "content", result.content
  end

  def test_publishing_without_title_raises_error
    user = Announcements::Users::RegularUser.new("creator_id")
    announcement = @announcements.add_new_draft(user)
    id = announcement.id
    @announcements.update_content(:system, id, "content") 

    assert_raises(Announcements::Errors::UnfinishedDraftError) do 
      @announcements.publish(:system, id)
    end
  end

  def test_publishing_without_content_raises_error
    user = Announcements::Users::RegularUser.new("creator_id")
    announcement = @announcements.add_new_draft(user)
    id = announcement.id
    @announcements.update_title(:system, id, "title") 

    assert_raises(Announcements::Errors::UnfinishedDraftError) do 
      @announcements.publish(:system, id)
    end
  end

  def test_title_update_authorization
    creator = Announcements::Users::RegularUser.new("creator_id")
    other_user = Announcements::Users::RegularUser.new("other_user_id")
    announcement = @announcements.add_new_draft(creator)
    id = announcement.id

    @announcements.update_title(:system, id, "title1")
    @announcements.update_title(creator, id, "title2")
    assert_raises(Announcements::Errors::AuthorizationError) do 
      @announcements.update_title(other_user, id, "title3") 
    end
  end

  def test_content_update_authorization
    creator = Announcements::Users::RegularUser.new("creator_id")
    other_user = Announcements::Users::RegularUser.new("other_user_id")
    announcement = @announcements.add_new_draft(creator)
    id = announcement.id

    @announcements.update_content(:system, id, "content1")
    @announcements.update_content(creator, id, "content2")
    assert_raises(Announcements::Errors::AuthorizationError) do 
      @announcements.update_content(other_user, id, "content3") 
    end
  end

  def test_publication_authorization
    creator = Announcements::Users::RegularUser.new("creator_id")
    other_user = Announcements::Users::RegularUser.new("other_user_id")
    announcement = @announcements.add_new_draft(creator)
    id = announcement.id
    @announcements.update_title(creator, id, "title")
    @announcements.update_content(creator, id, "content")

    @announcements.publish(:system, id)
    @announcements.publish(creator, id)
    assert_raises(Announcements::Errors::AuthorizationError) do 
      @announcements.publish(other_user, id) 
    end
  end
end
