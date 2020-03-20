require 'active_model_serializers'

module SolidusAffirm
  class LineItemSerializer < ActiveModel::Serializer
    attributes :display_name, :sku, :unit_price, :qty, :item_image_url, :item_url, :leasable

    def leasable
      true
    end

    def display_name
      object.name
    end

    def unit_price
      object.price.to_money.cents
    end

    def qty
      object.quantity
    end

    def item_image_url
      if object.variant.images.any?
        object.variant.images.first.attachment.url(:large)
      elsif object.variant.product.images.any?
        object.variant.product.images.first.attachment.url(:large)
      end
    end

    def item_url
      spree_routes.product_url(object.product)
    end

    private

    def spree_routes
      Spree::Core::Engine.routes.url_helpers
    end
  end
end
