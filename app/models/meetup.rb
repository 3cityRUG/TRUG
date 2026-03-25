class Meetup < ApplicationRecord
  DEFAULT_START_TIME = "18:00".freeze

  has_many :talks, dependent: :destroy
  has_many :attendances, dependent: :destroy

  attribute :event_type, :string
  attribute :start_time, :string, default: DEFAULT_START_TIME
  enum :event_type, { formal: "formal", bar: "bar" }, default: "formal"

  validates :number, presence: true, uniqueness: true, if: :formal?
  validates :date, presence: true
  validates :start_time, presence: true, format: { with: /\A([01]\d|2[0-3]):[0-5]\d\z/ }

  validate :cannot_change_to_bar_if_talks_exist, if: -> { bar? && event_type_changed? }

  before_validation :clear_number_for_bar_events, if: -> { bar? && number.present? }
  before_validation :apply_default_start_time

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

  def clear_number_for_bar_events
    self.number = nil
  end

  def apply_default_start_time
    self.start_time = DEFAULT_START_TIME if start_time.blank?
  end
end
