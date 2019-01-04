# frozen_string_literal: true

# This hack is needed because before v2.6 the API view that shows the order
# was trying to call the below methods on the payment source.
# The problem is that some sources, like the SolidusAffirm::Checkout,
# do not have these fields defined. We are creating these methods for
# older Solidus versions only and making them only return nil.
SolidusAffirm::Checkout.class_eval do
  %i[
    month
    year
    cc_type
    last_digits
    name
  ].each do |empty_method|
    define_method empty_method do
      nil
    end
  end
end
