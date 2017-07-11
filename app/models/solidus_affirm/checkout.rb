module SolidusAffirm
  class Checkout < ActiveRecord::Base
    self.table_name = "affirm_checkouts"

    def reusable?
      false
    end

    def actions
      %w(capture void credit)
    end
  end
end
