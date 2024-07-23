class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  validates :name, presence: true,
             length: {maximum: Settings.user.max_name_length}
  validates :email, presence: true,
             length: {maximum: Settings.user.max_email_length},
             format: {with: Regexp.new(Settings.user.email_regex, "i")},
             uniqueness: true
  validates :password, presence: true,
             length: {minimum: Settings.user.min_password_length},
             allow_nil: true

  has_secure_password

  scope :desc, ->{order created_at: :desc}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_token

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
