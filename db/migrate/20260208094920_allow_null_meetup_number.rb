class AllowNullMeetupNumber < ActiveRecord::Migration[8.1]
  def change
    change_column_null :meetups, :number, true
  end
end
