require 'spec_helper'

RSpec.describe SolidusAffirm::CheckoutPayloadSerializer do
  let(:affirm_checkout_payload) { SolidusAffirm::CheckoutPayload.new(order, config, metadata) }
  let(:serializer) { SolidusAffirm::CheckoutPayloadSerializer.new(affirm_checkout_payload, root: false) }
  let(:line_item_attributes) do
    [
      { product: create(:product, name: 'awesome product', sku: "P1") },
      { product: create(:product, name: 'amazing stuff', sku: "P2") }
    ]
  end
  let(:shipping_address) { create(:ship_address, firstname: "John", lastname: "Do", zipcode: "52106-9133") }
  let(:billing_address) { create(:bill_address, firstname: "John", lastname: "Do", zipcode: "58451") }

  let(:order) do
    create(:order_with_line_items,
      line_items_count: 2,
      line_items_attributes: line_item_attributes,
      ship_address: shipping_address,
      billing_address: billing_address)
  end
  let(:config) do
    {
      confirmation_url: "https://merchantsite.com/confirm",
      cancel_url: "https://merchantsite.com/cancel"
    }
  end
  let(:metadata) { {} }

  subject { JSON.parse(serializer.to_json) }

  it "wil have a 'merchant' object" do
    merchant_json = {
      "user_confirmation_url" => "https://merchantsite.com/confirm",
      "user_cancel_url" => "https://merchantsite.com/cancel"
    }
    expect(subject['merchant']).to eql merchant_json
  end

  it "will have a 'shipping' object" do
    shipping_json = {
      "name" => { "first" => "John", "last" => "Do" },
      "address" => {
        "line1" => "A Different Road",
        "line2" => "Northwest",
        "city" => "Herndon",
        "state" => "AL",
        "zipcode" => "52106-9133",
        "country" => "USA"
      }
    }
    expect(subject['shipping']).to eql shipping_json
  end

  it "will have a 'billing' object" do
    billing_json = {
      "name" => { "first" => "John", "last" => "Do" },
      "address" => {
        "line1" => "PO Box 1337",
        "line2" => "Northwest",
        "city" => "Herndon",
        "state" => "AL",
        "zipcode" => "58451",
        "country" => "USA"
      }
    }
    expect(subject['billing']).to eql billing_json
  end

  it "will have an 'order_id'" do
    expect(subject['order_id']).to eql order.number
  end

  it "will have a 'shipping_amount'" do
    expect(subject['shipping_amount']).to eql 10_000
  end

  it "will have a 'tax_amount'" do
    expect(subject['tax_amount']).to eql 0
  end

  it "will have a 'total'" do
    expect(subject['total']).to eql 12_000
  end

  describe "merchant object" do
    context "without an optional external name attribute" do
      it "will not expose a name subject key" do
        expect(subject['merchant']['user_confirmation_url']).to eql "https://merchantsite.com/confirm"
        expect(subject['merchant']['user_cancel_url']).to eql "https://merchantsite.com/cancel"
        expect(subject['merchant']['name']).to be_nil
      end
    end

    context "with the optional external name attribute present" do
      before do
        config[:name] = "Your Customer-Facing Merchant Name"
      end

      it "will expose the name subject key" do
        expect(subject['merchant']['user_confirmation_url']).to eql "https://merchantsite.com/confirm"
        expect(subject['merchant']['user_cancel_url']).to eql "https://merchantsite.com/cancel"
        expect(subject['merchant']['name']).to eql "Your Customer-Facing Merchant Name"
      end
    end
  end

  describe "items object" do
    let(:items_json) do
      [
        {
          "display_name" => "awesome product",
          "sku" => "P1",
          "unit_price" => 1000,
          "qty" => 1,
          "item_image_url" => nil,
          "item_url" => "http://shop.localhost:3000/products/awesome-product"
        },
        {
          "display_name" => "amazing stuff",
          "sku" => "P2",
          "unit_price" => 1000,
          "qty" => 1,
          "item_image_url" => nil,
          "item_url" => "http://shop.localhost:3000/products/amazing-stuff"
        }
      ]
    end

    it "returns an array with the serialized line items" do
      expect(subject["items"]).to eql items_json
    end
  end

  describe 'discounts' do
    context 'on an order without any promotions' do
      it "will not render a discounts key" do
        expect(subject['discounts']).to be_nil
      end
    end

    context 'on an order with promotions' do
      before do
        expect(order).to receive(:promo_total).and_return(BigDecimal("100.00"))
      end

      it "will aggregate the promotions into the discounts key" do
        output = subject
        expect(output['discounts']).to_not be_empty
        expect(output['discounts']['promotion_total']['discount_amount']).to eql 10_000
        expect(output['discounts']['promotion_total']['discount_display_name']).to eql "Total promotion discount"
      end
    end
  end

  describe 'metadata' do
    context 'when empty' do
      it "will not expose the metadata key" do
        expect(subject['metadata']).to be_nil
      end
    end

    context 'any hash' do
      let(:metadata) { { foo: 'bar' } }
      it "will expose that hash directly at the metadata key" do
        expect(subject['metadata']).to eql({ "foo" => "bar" })
      end
    end
  end
end
