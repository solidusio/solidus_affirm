module SolidusAffirm
  class Checkout < SolidusSupport.payment_source_parent_class
    self.table_name = "affirm_checkouts"

    def actions
      %w(capture void credit)
    end

    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def can_void?(payment)
      !payment.failed? && !payment.void?
    end

    def can_credit?(payment)
      payment.completed? && payment.credit_allowed > 0
    end
  end
end
