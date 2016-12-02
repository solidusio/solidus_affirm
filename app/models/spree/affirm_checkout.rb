module Spree
  class AffirmCheckout < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :order

    validate :validate_checkout_matches_order

    scope :with_payment_profile, -> { all }

    def name
      "Affirm Checkout"
    end

    def details
      @details ||= payment_method.provider.get_checkout token
    end

    def validate_checkout_matches_order
      return if self.id

      check_valid_products
      check_matching_shipping_address
      check_matching_billing_address
      check_matching_billing_email
      check_matching_product_key
    end

    def check_valid_products
      # ensure the number of line items matches
      if details["items"].size != order.line_items.size
        errors.add :line_items, "Order size mismatch"
      end

      # iterate through the line items of the checkout
      order.line_items.each do |line_item|

        # check that the line item sku exists in the affirm checkout
        if !(_item = details["items"][line_item.variant.sku])
          errors.add :line_items, "Line Item not in checkout details"

        # check quantity & price
        elsif _item["qty"].to_i   != line_item.quantity.to_i
          errors.add :line_items, "Quantity mismatch"

        elsif _item["unit_price"].to_i != (line_item.price*100).to_i
          errors.add :line_items, "Price mismatch"

        end
      end

      # all products match
      true
    end

    def check_matching_billing_address
      # ensure we have a standardized address format
      details['billing']['address'] = normalize_affirm_address details['billing']['address']

      # validate address
      check_address_match details["billing"], order.bill_address, :billing_address
    end

    def check_matching_shipping_address
      # ensure we have a standardized address format
      details['shipping']['address'] = normalize_affirm_address details['shipping']['address']

      # validate address
      check_address_match details["shipping"], order.ship_address, :shipping_address
    end

    def check_matching_billing_email
      if details["billing"]["email"].present? and details["billing"]["email"].casecmp(order.email) != 0
        errors.add :billing_email, "Billing email mismatch"
      end
    end

    def check_matching_product_key
      if details["config"]["financial_product_key"] != payment_method.preferred_product_key
        errors.add :financial_product_key, "Product key mismatch"
      end
    end

    def actions
      %w{capture void credit}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      (payment.pending? || payment.checkout?) && !payment.response_code.blank?
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      !payment.void? && payment.pending? && !payment.response_code.blank?
    end

    # Indicates whether its possible to credit the payment.  Note that most gateways require that the
    # payment be settled first which generally happens within 12-24 hours of the transaction.
    def can_credit?(payment)
      return false unless payment.completed?
      return false unless payment.order.payment_state == 'credit_owed'
      payment.credit_allowed > 0
    end

    private


    def normalize_affirm_address(affirm_address_details)
      Affirm::AddressValidator.normalize_affirm_address(affirm_address_details)
    end

    def check_address_match(affirm_address, spree_address, field)
      # mapping from affirm address keys to spree address values
      _key_mapping = {
        city:         spree_address.city,
        street1:      spree_address.address1,
        street2:      spree_address.address2,
        postal_code:  spree_address.zipcode,
        region1_code: spree_address.state.abbr

      # check that each value from affirm matches the spree address
      }.each do |affirm_key, spree_val|
        if affirm_address["address"][affirm_key.to_s].present? and
           affirm_address["address"][affirm_key.to_s] != spree_val

          errors.add field, "#{affirm_key.to_s} mismatch"
        end
      end

      # test affirm names with first and last
      if affirm_address["name"]["first"].present? and affirm_address["name"]["last"].present? and
        (affirm_address["name"]["first"].casecmp(spree_address.firstname) != 0 or
         affirm_address["name"]["last"].casecmp(spree_address.lastname) != 0)

        errors.add field, "First/Last name mismatch"

      # test affirm names with full name
      elsif affirm_address["name"]["full"].present? and
          !(affirm_address["name"]["full"].downcase.include?(spree_address.firstname.downcase) and
            affirm_address["name"]["full"].downcase.include?(spree_address.lastname.downcase))

        errors.add field, "Full name mismatch"
      end
    end

  end
end
