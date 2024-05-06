class AddCubeAndEarthdistanceExtension < ActiveRecord::Migration[7.1]
  def up
    execute "CREATE EXTENSION cube;"
    execute "CREATE EXTENSION earthdistance;"
  end
end
