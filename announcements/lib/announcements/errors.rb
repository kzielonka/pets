class Announcements
  module Errors
    AuthorizationError = Class.new(RuntimeError)
    UnfinishedDraftError = Class.new(RuntimeError)
  end
end
