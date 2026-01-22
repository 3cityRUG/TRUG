class CreateMeetups < ActiveRecord::Migration[8.1]
  def change
    create_table :meetups do |t|
      t.integer :number, null: false
      t.date :date, null: false
      t.string :location
      t.text :description
      t.timestamps
    end

    add_index :meetups, :number, unique: true
  end
end
