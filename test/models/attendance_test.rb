require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "valid attendance with meetup and github_username" do
    attendance = Attendance.new(
      meetup: meetups(:one),
      github_username: "testuser",
      status: Attendance::STATUSES[:yes]
    )
    assert attendance.valid?
  end

  test "invalid without meetup" do
    attendance = Attendance.new(
      github_username: "testuser",
      status: Attendance::STATUSES[:yes]
    )
    assert_not attendance.valid?
    assert attendance.errors[:meetup_id].any?
  end

  test "invalid without github_username" do
    attendance = Attendance.new(
      meetup: meetups(:one),
      status: Attendance::STATUSES[:yes]
    )
    assert_not attendance.valid?
    assert attendance.errors[:github_username].any?
  end

  test "invalid without status" do
    attendance = Attendance.new(
      meetup: meetups(:one),
      github_username: "testuser"
    )
    assert_not attendance.valid?
    assert attendance.errors[:status].any?
  end

  test "invalid with invalid status value" do
    attendance = Attendance.new(
      meetup: meetups(:one),
      github_username: "testuser",
      status: 999
    )
    assert_not attendance.valid?
    assert attendance.errors[:status].any?
  end

  test "belongs to meetup" do
    attendance = attendances(:attendance_one)
    assert_equal meetups(:one), attendance.meetup
  end

  test "belongs to user (optional)" do
    attendance = attendances(:attendance_one)
    assert_equal users(:user_one), attendance.user
  end

  test "can exist without user" do
    attendance = attendances(:attendance_without_user)
    assert_nil attendance.user
    assert attendance.valid?
  end

  test "status constants" do
    assert_equal 0, Attendance::STATUSES[:maybe]
    assert_equal 1, Attendance::STATUSES[:yes]
    assert_equal 2, Attendance::STATUSES[:no]
  end

  test "status_name returns string for valid status" do
    attendance = Attendance.new(status: Attendance::STATUSES[:yes])
    assert_equal "yes", attendance.status_name
  end

  test "status_name returns nil for nil status" do
    attendance = Attendance.new(status: nil)
    assert_nil attendance.status_name
  end

  test "scope for_meetup filters by meetup" do
    meetup = meetups(:one)
    attendances = Attendance.for_meetup(meetup)
    assert attendances.all? { |a| a.meetup_id == meetup.id }
  end

  test "scope confirmed returns only yes status" do
    confirmed = Attendance.confirmed
    assert confirmed.all? { |a| a.status == Attendance::STATUSES[:yes] }
  end
end
