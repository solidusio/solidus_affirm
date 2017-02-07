module SolidusAffirm
  class Checkout < ActiveRecord::Base
    self.table_name = "affirm_checkouts"

    def actions
      %w(capture void credit)
    end
  end
end
