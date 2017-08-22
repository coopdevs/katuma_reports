class Exchange < ActiveRecord::Base
  belongs_to :order_cycle
  belongs_to :sender, class_name: 'Enterprise'
  belongs_to :receiver, class_name: 'Enterprise', touch: true

  has_many :exchange_fees, dependent: :destroy

  has_many :exchange_variants, dependent: :destroy
  has_many :variants, through: :exchange_variants
end
