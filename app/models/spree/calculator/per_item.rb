module Spree
  class Calculator::PerItem < Calculator
    preference :amount, :decimal, default: 0

    attr_accessible :preferred_amount
  end
end
