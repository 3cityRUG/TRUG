class Talk < ApplicationRecord
  belongs_to :meetup
  validates :title, presence: true
  validates :speaker_name, presence: true
end
