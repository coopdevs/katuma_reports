class ExchangeFee < ActiveRecord::Base
  belongs_to :exchange
  belongs_to :enterprise_fee

  attr_accessible :exchange, :enterprise_fee
end
