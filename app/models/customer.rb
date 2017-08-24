class Customer < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :user, class_name: Spree::User
  belongs_to :bill_address, foreign_key: :bill_address_id, class_name: Spree::Address

  has_many :orders, class_name: Spree::Order

  def name
    super || 'Guest'
  end
end
