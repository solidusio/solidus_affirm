json.name do
  json.first address.first_name
  json.last address.last_name
end

json.address do
  json.line1 address.address1
  json.city address.city
  json.state address.state ? address.state.abbr : address.state_name
  json.zipcode address.zipcode
end

json.phone_number address.phone
json.email @order.email || @order.user.try!(:email)
