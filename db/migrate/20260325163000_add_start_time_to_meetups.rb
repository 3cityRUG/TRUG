class AddStartTimeToMeetups < ActiveRecord::Migration[8.1]
  def up
    add_column :meetups, :start_time, :string, default: "18:00", null: false
  end

  def down
    remove_column :meetups, :start_time
  end
end
