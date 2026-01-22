class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.integer :meetup_id
      t.integer :user_id
      t.integer :status
      t.string :github_username

      t.timestamps
    end
  end
end
