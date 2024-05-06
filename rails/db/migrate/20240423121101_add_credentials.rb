class AddCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :credentials, id: :uuid do |t|
      t.uuid :user_id, null: false, index: { unique: true }
      t.string :email, null: false, index: { unique: true }
      t.string :password, null: false 
      t.timestamps
    end
  end
end
