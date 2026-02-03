class AddEventTypeToMeetups < ActiveRecord::Migration[8.1]
  def up
    add_column :meetups, :event_type, :string, default: 'formal'
    add_index :meetups, :event_type
    change_column :meetups, :number, :integer, null: true
  end

  def down
    change_column :meetups, :number, :integer, null: false
    remove_index :meetups, :event_type
    remove_column :meetups, :event_type
  end
end
