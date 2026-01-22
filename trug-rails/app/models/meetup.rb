class Meetup < ApplicationRecord
  has_many :talks, dependent: :destroy
  has_many :attendances, dependent: :destroy
  validates :number, presence: true, uniqueness: true
  validates :date, presence: true
  scope :ordered, -> { order(date: :desc) }
  scope :upcoming, -> { where("date >= ?", Date.today).order(date: :asc) }
  scope :past, -> { where("date < ?", Date.today).order(date: :desc) }
end
