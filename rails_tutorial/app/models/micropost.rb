class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [Settings.image.width,
                                         Settings.image.height]
  end

  validates :user_id, presence: true
  validates :content, presence: true,
                      length: {maximum: Settings.micropost.max_content_length}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png)},
                    size: {less_than: Settings.image.size_5.megabytes}

  scope :desc, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
end
