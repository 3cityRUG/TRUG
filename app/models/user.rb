class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.from_github(github_data)
    user = find_or_initialize_by(github_id: github_data["id"].to_s)
    unless user.persisted?
      user.github_username = github_data["login"]
      user.email_address = github_data["email"] || "#{github_data["login"]}@github.local"
      user.password = SecureRandom.hex(32)
      user.save!
    end
    user
  end

  def github?
    github_id.present?
  end
end
