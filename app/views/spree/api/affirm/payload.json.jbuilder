json.merchant do
  json.user_cancel_url cancel_affirm_url
  json.user_confirmation_url confirm_affirm_url
  json.user_confirmation_url_action "POST"
end

json.shipping do
  address = @order.ship_address
  json.partial! 'address', address: address
end

json.billing do
  address = @order.bill_address
  json.partial! 'address', address: address
end

json.items @order.line_items do |line_item|
  json.display_name line_item.name
  json.sku line_item.sku
  json.unit_price line_item.price.to_money.cents
  json.qty line_item.quantity
  json.item_url spree.product_url(line_item.product)

  if image = line_item.variant.images.first
    json.item_image_url root_url + image.attachment.url
  end
end

json.currency @order.currency
json.order_id @order.number

if !@order.promo_total.zero?
  json.discounts do
    json.promotions do
      json.discount_amount @order.promo_total * -1
      json.discount_display_name "Promotions & Discounts"
    end
  end
end

json.shipping_amount @order.shipment_total.to_money.cents
json.tax_amount @order.tax_total.to_money.cents
json.total @order.order_total_after_store_credit.to_money.cents
