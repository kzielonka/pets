class Announcements
  module Errors
    AuthorizationError = Class.new(RuntimeError)
    UnfinishedDraftError = Class.new(RuntimeError)
    CanNotEditPublishedAnnouncementError = Class.new(RuntimeError)
  end
end
