FactoryBot.define do
  factory :affirm_payment_gateway, class: SolidusAffirm::Gateway do
    name "Affirm"
  end
end
