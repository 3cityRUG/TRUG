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
end
