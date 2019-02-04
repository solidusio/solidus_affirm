FactoryBot.define do
  factory :affirm_payment, class: Spree::Payment do
    source_type { 'SolidusAffirm::Checkout' }
    state { 'checkout' }
  end

  factory :captured_affirm_payment, class: Spree::Payment do
    payment_method { create(:affirm_payment_gateway) }
    source { create(:affirm_checkout) }
    response_code { '123456789' }
  end
end
