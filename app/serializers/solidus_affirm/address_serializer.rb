require "active_model_serializers"

module SolidusAffirm
  class AddressSerializer < ActiveModel::Serializer
    attributes :name, :address

    def name
      if SolidusSupport.combined_first_and_last_name_in_address?
        full_name = Spree::Address::Name.new(object.name)
        {
          first: full_name.first_name,
          last: full_name.last_name
        }
      else
        {
          first: object.first_name,
          last: object.last_name
        }
      end
    end

    def address
      {
        line1: object.address1,
        line2: object.address2,
        city: object.city,
        state: object.state&.abbr,
        zipcode: object.zipcode,
        country: object.country.iso3
      }
    end
  end
end
