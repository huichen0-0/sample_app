class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true,
             length: {maximum: Settings.user.max_name_length}
  validates :email, presence: true,
             length: {maximum: Settings.user.max_email_length},
             format: {with: Regexp.new(Settings.user.email_regex, "i")},
             uniqueness: true

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end
  end

  private
  def downcase_email
    email.downcase!
  end
end
