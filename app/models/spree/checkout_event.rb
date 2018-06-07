module Spree
  class CheckoutEvent < Spree::Base

    with_options polymorphic: true, optional: true do
      belongs_to :actor
      belongs_to :target
    end

    validates :activity,
              :session_id,
              :target, presence: true
  end
end
