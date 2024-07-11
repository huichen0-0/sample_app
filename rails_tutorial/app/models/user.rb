class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true, 
             length: {maximum: Settings.user.max_name_length}
  validates :email, presence: true, 
             length: {maximum: Settings.user.max_email_length},
             format: {with: Regexp.new(Settings.user.email_regex)},
             uniqueness: true

  has_secure_password

  private
  def downcase_email
    email.downcase!
  end
end