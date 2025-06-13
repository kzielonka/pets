# Load module migrations from each module's db/migrate directory
module_migration_paths = Dir.glob(Rails.root.join("../modules/*/db/migrate"))

module_migration_paths.each do |path|
  Rails.application.config.paths["db/migrate"] << path
end 