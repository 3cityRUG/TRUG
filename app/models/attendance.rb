class Attendance < ApplicationRecord
  belongs_to :meetup
  belongs_to :user, optional: true

  STATUSES = { maybe: 0, yes: 1, no: 2 }.freeze

  validates :meetup_id, presence: true
  validates :github_username, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.values }

  scope :for_meetup, ->(meetup) { where(meetup_id: meetup.id) }
  scope :confirmed, -> { where(status: STATUSES[:yes]) }

  def status_name
    STATUSES.key(status).to_s if status.present?
  end

  # Cycles through: yes (1) -> maybe (0) -> no (2) -> yes (1)
  def next_status
    case status
    when STATUSES[:yes] then STATUSES[:maybe]
    when STATUSES[:maybe] then STATUSES[:no]
    when STATUSES[:no] then STATUSES[:yes]
    else STATUSES[:yes]
    end
  end

  def status_label
    case status
    when STATUSES[:yes] then "Tak, będę!"
    when STATUSES[:maybe] then "Może"
    when STATUSES[:no] then "Nie będę"
    else "Nieznany"
    end
  end

  def self.status_label(status_value)
    case status_value
    when STATUSES[:yes] then "Tak, będę!"
    when STATUSES[:maybe] then "Może"
    when STATUSES[:no] then "Nie będę"
    else "Nieznany"
    end
  end
end
