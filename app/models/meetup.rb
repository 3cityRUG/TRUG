class Meetup < ApplicationRecord
  has_many :talks, dependent: :destroy
  has_many :attendances, dependent: :destroy

  enum :event_type, { formal: "formal", bar: "bar" }, default: "formal"

  validates :number, presence: true, uniqueness: true, if: :formal?
  validates :date, presence: true

  validate :cannot_change_to_bar_if_talks_exist, if: -> { bar? && event_type_changed? }

  scope :ordered, -> { order(Arel.sql("CASE WHEN event_type = 'bar' THEN 1 ELSE 0 END, date DESC")) }
  scope :upcoming, -> { where("date >= ?", Date.today).order(date: :asc) }
  scope :past, -> { where("date < ?", Date.today).order(date: :desc) }
  scope :formal, -> { where(event_type: "formal") }
  scope :bar, -> { where(event_type: "bar") }
  scope :archived, -> { formal.past }

  private

  def cannot_change_to_bar_if_talks_exist
    errors.add(:event_type, "cannot be changed to Bar TRUG because it has talks") if talks.any?
  end
end
